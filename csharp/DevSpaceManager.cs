#:package System.CommandLine@2.0.0-beta4.22272.1
#:package Newtonsoft.Json@13.0.3
#:package Spectre.Console@0.48.0

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Diagnostics;
using System.CommandLine;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Spectre.Console;

public class Program
{
    public static async Task<int> Main(string[] args)
    {
        var rootCommand = new RootCommand("DevSpace Manager - Backup and restore development workspace repositories");

        // Create backup command
        var devFolderArg = new Argument<string>("devFolder", "Path to the development folder to backup");
        var forceOption = new Option<bool>(new[] { "--force", "-f" }, "Force rebuild of dev.json file");
        var backupCommand = new Command("backup", "Backup repository information from dev folder");
        backupCommand.AddArgument(devFolderArg);
        backupCommand.AddOption(forceOption);
        backupCommand.SetHandler(async (string devFolder, bool force) =>
        {
            await BackupDevSpace(devFolder, force);
        }, devFolderArg, forceOption);

        // Create restore command
        var devFolderRestoreArg = new Argument<string>("devFolder", "Path to the development folder containing dev.json");
        var dryRunOption = new Option<bool>(new[] { "--dry-run", "-d" }, "Show what would be done without actually doing it");
        var restoreCommand = new Command("restore", "Restore repositories from dev.json backup file");
        restoreCommand.AddArgument(devFolderRestoreArg);
        restoreCommand.AddOption(dryRunOption);
        restoreCommand.SetHandler(async (string devFolder, bool dryRun) =>
        {
            await RestoreDevSpace(devFolder, dryRun);
        }, devFolderRestoreArg, dryRunOption);

        // Create diff command
        var devFolderDiffArg = new Argument<string>("devFolder", "Path to the development folder to compare");
        var diffCommand = new Command("diff", "Compare current repositories with dev.json backup file");
        diffCommand.AddArgument(devFolderDiffArg);
        diffCommand.SetHandler(async (string devFolder) =>
        {
            await DiffDevSpace(devFolder);
        }, devFolderDiffArg);

        rootCommand.AddCommand(backupCommand);
        rootCommand.AddCommand(restoreCommand);
        rootCommand.AddCommand(diffCommand);

        return await rootCommand.InvokeAsync(args);
    }

    // Backup functionality
    static async Task BackupDevSpace(string devFolder, bool force)
    {
        AnsiConsole.Write(new FigletText("DevSpace Backup").Centered().Color(Color.Blue));

        if (!Directory.Exists(devFolder))
        {
            AnsiConsole.MarkupLine($"[red]✗[/] Development folder '[yellow]{devFolder}[/]' does not exist.");
            return;
        }

        var devJsonPath = Path.Combine(devFolder, "dev.json");
        var repoInfo = new Dictionary<string, Dictionary<string, RepositoryInfo>>();

        AnsiConsole.MarkupLine($"[green]📁[/] Scanning development folder: [cyan]{devFolder}[/]");

        // Load existing data or initialize
        if (force)
        {
            // Backup existing dev.json if it exists
            if (File.Exists(devJsonPath))
            {
                var timestamp = DateTimeOffset.UtcNow.ToUnixTimeSeconds();
                var backupPath = Path.Combine(devFolder, $"dev_{timestamp}.json");
                try
                {
                    File.Copy(devJsonPath, backupPath);
                    AnsiConsole.MarkupLine($"[blue]💾[/] Backed up existing file to [cyan]{Path.GetFileName(backupPath)}[/]");
                }
                catch (Exception ex)
                {
                    AnsiConsole.MarkupLine($"[orange3]⚠[/] Could not backup existing file: {ex.Message}");
                }
            }

            AnsiConsole.MarkupLine($"[yellow]🔄[/] Force rebuilding [cyan]{devJsonPath}[/]...");
            repoInfo = new Dictionary<string, Dictionary<string, RepositoryInfo>>();
        }
        else if (File.Exists(devJsonPath))
        {
            AnsiConsole.MarkupLine($"[blue]📄[/] Loading existing backup from [cyan]{devJsonPath}[/]...");
            try
            {
                var json = await File.ReadAllTextAsync(devJsonPath);
                var deserializedInfo = JsonConvert.DeserializeObject<Dictionary<string, Dictionary<string, RepositoryInfo>>>(json);
                repoInfo = deserializedInfo ?? new Dictionary<string, Dictionary<string, RepositoryInfo>>();
            }
            catch (Exception ex)
            {
                AnsiConsole.MarkupLine($"[red]⚠[/] Error loading existing file: {ex.Message}");
                AnsiConsole.MarkupLine($"[yellow]🆕[/] Creating new backup...");
                repoInfo = new Dictionary<string, Dictionary<string, RepositoryInfo>>();
            }
        }
        else
        {
            AnsiConsole.MarkupLine($"[yellow]🆕[/] No existing backup found. Creating new backup...");
            repoInfo = new Dictionary<string, Dictionary<string, RepositoryInfo>>();
        }

        Console.WriteLine();

        // Store existing state for comparison (if not force rebuild)
        var existingRepoInfo = new Dictionary<string, Dictionary<string, RepositoryInfo>>(repoInfo);

        // Scan for repositories in the dev folder (multi-threaded)
        AnsiConsole.MarkupLine($"[green]🔍[/] Scanning repositories...");
        var currentRepoInfo = new Dictionary<string, Dictionary<string, RepositoryInfo>>();
        await ScanForRepositoriesAsync(devFolder, currentRepoInfo);

        // Compare changes if we had existing data (not force rebuild)
        DiffResult? diffResult = null;
        if (!force && existingRepoInfo.Count > 0)
        {
            diffResult = CompareRepositories(existingRepoInfo, currentRepoInfo);

            // Show differences
            Console.WriteLine();
            AnsiConsole.MarkupLine($"[blue]📊[/] Changes detected:");
            AnsiConsole.MarkupLine($"  [green]+ {diffResult.NewlyAdded.Count}[/] newly added repositories");
            AnsiConsole.MarkupLine($"  [red]- {diffResult.Missing.Count}[/] missing repositories");
        }

        // Merge with existing or use current
        if (force)
        {
            repoInfo = currentRepoInfo;
        }
        else
        {
            // Merge current scan results with existing data
            foreach (var folder in currentRepoInfo)
            {
                repoInfo[folder.Key] = folder.Value;
            }
        }

        // Save to JSON file
        try
        {
            var jsonOutput = JsonConvert.SerializeObject(repoInfo, Formatting.Indented);
            await File.WriteAllTextAsync(devJsonPath, jsonOutput);

            var totalRepos = repoInfo.Values.Sum(folder => folder.Count);

            Console.WriteLine();

            // Create summary table
            var table = new Table()
                .Border(TableBorder.Rounded)
                .BorderColor(Color.Blue)
                .AddColumn("[bold]Folder[/]")
                .AddColumn("[bold]Repositories[/]");

            foreach (var folder in repoInfo.OrderBy(f => f.Key))
            {
                table.AddRow(
                    $"[cyan]{folder.Key}[/]",
                    $"[green]{folder.Value.Count}[/]"
                );
            }

            AnsiConsole.Write(table);

            AnsiConsole.MarkupLine($"\n[green]✓[/] Backup completed successfully!");
            AnsiConsole.MarkupLine($"[blue]📊[/] Total: [bold green]{totalRepos}[/] repositories across [bold green]{repoInfo.Count}[/] folders");
            AnsiConsole.MarkupLine($"[blue]💾[/] Saved to: [cyan]{devJsonPath}[/]");

            // Show summary of changes if we have diff results
            if (diffResult != null && (diffResult.NewlyAdded.Count > 0 || diffResult.Missing.Count > 0))
            {
                AnsiConsole.MarkupLine($"\n[blue]💡[/] Use [cyan]diff[/] command to see detailed changes");
            }
        }
        catch (Exception ex)
        {
            AnsiConsole.MarkupLine($"[red]✗[/] Error saving to file '[yellow]{devJsonPath}[/]': {ex.Message}");
        }
    }

    // Restore functionality
    static async Task RestoreDevSpace(string devFolder, bool dryRun)
    {
        AnsiConsole.Write(new FigletText("DevSpace Restore").Centered().Color(Color.Green));

        if (!Directory.Exists(devFolder))
        {
            AnsiConsole.MarkupLine($"[red]✗[/] Development folder '[yellow]{devFolder}[/]' does not exist.");
            return;
        }

        var devJsonPath = Path.Combine(devFolder, "dev.json");

        // Check if dev.json exists
        if (!File.Exists(devJsonPath))
        {
            AnsiConsole.MarkupLine($"[red]✗[/] No dev.json found in target folder '[yellow]{devFolder}[/]'.");
            AnsiConsole.MarkupLine($"[blue]💡[/] Please run [cyan]backup[/] command first to create the backup file.");
            return;
        }

        // Load repository information
        Dictionary<string, Dictionary<string, RepositoryInfo>> repoInfo;
        try
        {
            var json = await File.ReadAllTextAsync(devJsonPath);
            var deserializedInfo = JsonConvert.DeserializeObject<Dictionary<string, Dictionary<string, RepositoryInfo>>>(json);
            if (deserializedInfo == null)
            {
                AnsiConsole.MarkupLine($"[red]✗[/] Could not parse repository information from '[yellow]{devJsonPath}[/]'.");
                return;
            }
            repoInfo = deserializedInfo;
        }
        catch (Exception ex)
        {
            AnsiConsole.MarkupLine($"[red]✗[/] Error loading repository information from '[yellow]{devJsonPath}[/]': {ex.Message}");
            return;
        }

        AnsiConsole.MarkupLine($"[green]📄[/] Loaded backup from: [cyan]{devJsonPath}[/]");
        if (dryRun)
        {
            AnsiConsole.MarkupLine($"[yellow]🔍[/] [bold]DRY RUN MODE[/] - No actual changes will be made");
        }

        var totalRepos = repoInfo.Values.Sum(folder => folder.Count);
        AnsiConsole.MarkupLine($"[blue]📊[/] Found [bold green]{totalRepos}[/] repositories across [bold green]{repoInfo.Count}[/] folders");

        Console.WriteLine();

        // Process each folder with simplified output
        var processedCount = 0;
        var clonedCount = 0;
        var warningsCount = 0;

        // Process folders in parallel with Progress control
        await AnsiConsole.Progress()
            .Columns(new ProgressColumn[]
            {
                new TaskDescriptionColumn(),    // Only show task description (status)
                new SpinnerColumn(),           // Show spinner for activity indication
            })
            .StartAsync(async ctx =>
            {
                // Create progress tasks for each folder
                var folderProgressTasks = repoInfo.ToDictionary(
                    kvp => kvp.Key,
                    kvp => ctx.AddTask($"[cyan]{kvp.Key}[/]: Initializing...")
                );

                // Process folders in parallel
                var folderTasks = repoInfo.Select(async folder =>
                {
                    var progressTask = folderProgressTasks[folder.Key];
                    return await RestoreRepositoriesWithProgressAsync(devFolder, folder.Key, folder.Value, dryRun, progressTask);
                });

                var results = await Task.WhenAll(folderTasks);

                // Mark all tasks as completed
                foreach (var task in folderProgressTasks.Values)
                {
                    task.Description = $"[green]✓[/] {task.Description.Replace("Initializing...", "Completed")}";
                    task.Value = 100;
                }

                foreach (var result in results)
                {
                    processedCount += result.processed;
                    clonedCount += result.cloned;
                    warningsCount += result.warnings;
                }
            });

        // Summary
        var summaryTable = new Table()
            .Border(TableBorder.Rounded)
            .BorderColor(dryRun ? Color.Yellow : Color.Green)
            .AddColumn("[bold]Status[/]")
            .AddColumn("[bold]Count[/]")
            .AddColumn("[bold]Description[/]");

        summaryTable.AddRow(
            "[green]✓ Processed[/]",
            $"[bold]{processedCount}[/]",
            "Repositories checked"
        );

        if (clonedCount > 0)
        {
            summaryTable.AddRow(
                dryRun ? "[yellow]Would Clone[/]" : "[blue]✓ Cloned[/]",
                $"[bold]{clonedCount}[/]",
                "New repositories " + (dryRun ? "would be cloned" : "cloned")
            );
        }

        if (warningsCount > 0)
        {
            summaryTable.AddRow(
                "[orange3]⚠ Warnings[/]",
                $"[bold]{warningsCount}[/]",
                "Branch or remote mismatches"
            );
        }

        AnsiConsole.Write(summaryTable);

        if (dryRun)
        {
            AnsiConsole.MarkupLine($"\n[yellow]🔍[/] [bold]DRY RUN COMPLETED[/] - No actual changes were made");
            AnsiConsole.MarkupLine($"[blue]💡[/] Run without [cyan]--dry-run[/] to perform the actual restoration");
        }
        else
        {
            AnsiConsole.MarkupLine($"\n[green]✓[/] [bold]Repository restoration completed successfully![/]");
        }
    }

    // Diff functionality
    static async Task DiffDevSpace(string devFolder)
    {
        AnsiConsole.Write(new FigletText("DevSpace Diff").Centered().Color(Color.Purple));

        if (!Directory.Exists(devFolder))
        {
            AnsiConsole.MarkupLine($"[red]✗[/] Development folder '[yellow]{devFolder}[/]' does not exist.");
            return;
        }

        var devJsonPath = Path.Combine(devFolder, "dev.json");

        // Check if dev.json exists
        if (!File.Exists(devJsonPath))
        {
            AnsiConsole.MarkupLine($"[red]✗[/] No dev.json found in target folder '[yellow]{devFolder}[/]'.");
            AnsiConsole.MarkupLine($"[blue]💡[/] Please run [cyan]backup[/] command first to create the backup file.");
            return;
        }

        // Load existing backup
        Dictionary<string, Dictionary<string, RepositoryInfo>> existingRepoInfo;
        try
        {
            var json = await File.ReadAllTextAsync(devJsonPath);
            var deserializedInfo = JsonConvert.DeserializeObject<Dictionary<string, Dictionary<string, RepositoryInfo>>>(json);
            if (deserializedInfo == null)
            {
                AnsiConsole.MarkupLine($"[red]✗[/] Could not parse repository information from '[yellow]{devJsonPath}[/]'.");
                return;
            }
            existingRepoInfo = deserializedInfo;
        }
        catch (Exception ex)
        {
            AnsiConsole.MarkupLine($"[red]✗[/] Error loading repository information from '[yellow]{devJsonPath}[/]': {ex.Message}");
            return;
        }

        // Get current repository state (multi-threaded)
        var currentRepoInfo = new Dictionary<string, Dictionary<string, RepositoryInfo>>();
        AnsiConsole.MarkupLine($"[green]📄[/] Loaded backup from: [cyan]{devJsonPath}[/]");
        AnsiConsole.MarkupLine($"[green]🔍[/] Scanning current repositories...");
        await ScanForRepositoriesAsync(devFolder, currentRepoInfo);

        Console.WriteLine();

        // Compare and show differences
        var diffResult = CompareRepositories(existingRepoInfo, currentRepoInfo);

        // Display results
        DisplayDiffResults(diffResult);
    }

    // Compare two repository states and return differences
    static DiffResult CompareRepositories(
        Dictionary<string, Dictionary<string, RepositoryInfo>> existing,
        Dictionary<string, Dictionary<string, RepositoryInfo>> current)
    {
        var result = new DiffResult();

        // Find all folders in both states
        var allFolders = existing.Keys.Union(current.Keys).ToHashSet();

        foreach (var folder in allFolders)
        {
            var existingRepos = existing.ContainsKey(folder) ? existing[folder] : new Dictionary<string, RepositoryInfo>();
            var currentRepos = current.ContainsKey(folder) ? current[folder] : new Dictionary<string, RepositoryInfo>();

            // Find newly added repositories
            foreach (var repo in currentRepos)
            {
                if (!existingRepos.ContainsKey(repo.Key))
                {
                    result.NewlyAdded.Add(new RepoLocation { Folder = folder, Path = repo.Key, Info = repo.Value });
                }
            }

            // Find missing repositories
            foreach (var repo in existingRepos)
            {
                if (!currentRepos.ContainsKey(repo.Key))
                {
                    result.Missing.Add(new RepoLocation { Folder = folder, Path = repo.Key, Info = repo.Value });
                }
            }
        }

        return result;
    }

    // Display diff results
    static void DisplayDiffResults(DiffResult diff)
    {
        // Summary
        AnsiConsole.MarkupLine($"[blue]📊[/] Comparison Summary:");
        AnsiConsole.MarkupLine($"  [green]+ {diff.NewlyAdded.Count}[/] newly added repositories");
        AnsiConsole.MarkupLine($"  [red]- {diff.Missing.Count}[/] missing repositories");

        Console.WriteLine();

        // Newly added repositories
        if (diff.NewlyAdded.Count > 0)
        {
            var newTable = new Table()
                .Border(TableBorder.Rounded)
                .BorderColor(Color.Green)
                .Title("[bold green]Newly Added Repositories[/]")
                .AddColumn("[bold]Folder[/]")
                .AddColumn("[bold]Repository Path[/]")
                .AddColumn("[bold]Branch[/]")
                .AddColumn("[bold]Remote[/]");

            foreach (var repo in diff.NewlyAdded.OrderBy(r => r.Folder).ThenBy(r => r.Path))
            {
                newTable.AddRow(
                    $"[cyan]{repo.Folder}[/]",
                    $"[dim]{repo.Path}[/]",
                    $"[yellow]{repo.Info.Branch}[/]",
                    $"[blue]{TruncateUrl(repo.Info.Remote)}[/]"
                );
            }

            AnsiConsole.Write(newTable);
            Console.WriteLine();
        }

        // Missing repositories
        if (diff.Missing.Count > 0)
        {
            var missingTable = new Table()
                .Border(TableBorder.Rounded)
                .BorderColor(Color.Red)
                .Title("[bold red]Missing Repositories[/]")
                .AddColumn("[bold]Folder[/]")
                .AddColumn("[bold]Repository Path[/]")
                .AddColumn("[bold]Branch[/]")
                .AddColumn("[bold]Remote[/]");

            foreach (var repo in diff.Missing.OrderBy(r => r.Folder).ThenBy(r => r.Path))
            {
                missingTable.AddRow(
                    $"[cyan]{repo.Folder}[/]",
                    $"[dim]{repo.Path}[/]",
                    $"[yellow]{repo.Info.Branch}[/]",
                    $"[blue]{TruncateUrl(repo.Info.Remote)}[/]"
                );
            }

            AnsiConsole.Write(missingTable);
            Console.WriteLine();
        }

        if (diff.NewlyAdded.Count == 0 && diff.Missing.Count == 0)
        {
            AnsiConsole.MarkupLine($"[green]✓[/] [bold]No differences found![/] Current state matches the backup.");
        }
    }

    // Helper method to truncate long URLs for display
    static string TruncateUrl(string url, int maxLength = 50)
    {
        if (string.IsNullOrEmpty(url) || url.Length <= maxLength)
            return url;

        return url.Substring(0, maxLength - 3) + "...";
    }

    // Multi-threaded restore repositories with Progress control
    static async Task<(int processed, int cloned, int warnings)> RestoreRepositoriesWithProgressAsync(string baseFolder, string folderName, Dictionary<string, RepositoryInfo> repositories, bool dryRun, ProgressTask progressTask)
    {
        const int maxRestoreParallelism = 3; // Limit parallel restore operations (git clone is I/O intensive)
        var targetFolder = Path.Combine(baseFolder, folderName);
        var processed = 0;
        var cloned = 0;
        var warnings = 0;

        AnsiConsole.MarkupLine($"[cyan]📂 {folderName}[/]: {repositories.Count} repositories");

        // Ensure target folder exists
        if (!Directory.Exists(targetFolder) && !dryRun)
        {
            try
            {
                Directory.CreateDirectory(targetFolder);
            }
            catch (Exception ex)
            {
                AnsiConsole.MarkupLine($"  [red]✗[/] Could not create directory '{targetFolder}': {ex.Message}");
                return (0, 0, 0);
            }
        }

        var semaphore = new SemaphoreSlim(maxRestoreParallelism, maxRestoreParallelism);
        var lockObject = new object();

        var tasks = repositories.Select(async repo =>
        {
            await semaphore.WaitAsync();
            try
            {
                var relativePath = repo.Key;
                var repoInfo = repo.Value;
                var fullPath = Path.Combine(targetFolder, relativePath);

                lock (lockObject)
                {
                    processed++;
                }

                // Update status for current operation
                progressTask.Description = $"[cyan]{folderName}[/]: Checking [dim]{relativePath}[/]...";

                // Check if repository already exists
                if (Directory.Exists(fullPath))
                {
                    if (Directory.Exists(Path.Combine(fullPath, ".git")))
                    {
                        // Run git commands asynchronously
                        progressTask.Description = $"[cyan]{folderName}[/]: Verifying [dim]{relativePath}[/]...";

                        var branchTask = Task.Run(() => GetCurrentBranch(fullPath));
                        var remoteTask = Task.Run(() => ExecuteGitCommand(fullPath, "remote get-url origin"));

                        await Task.WhenAll(branchTask, remoteTask);

                        var currentBranch = branchTask.Result;
                        var currentRemote = remoteTask.Result;

                        if (!string.IsNullOrEmpty(currentBranch) && currentBranch != repoInfo.Branch)
                        {
                            lock (lockObject)
                            {
                                warnings++;
                            }
                            AnsiConsole.MarkupLine($"  [orange3]⚠[/] [dim]{relativePath}[/]: Branch mismatch ([yellow]{currentBranch}[/] → [cyan]{repoInfo.Branch}[/])");
                        }

                        if (!string.IsNullOrEmpty(currentRemote) && currentRemote != repoInfo.Remote)
                        {
                            lock (lockObject)
                            {
                                warnings++;
                            }
                            AnsiConsole.MarkupLine($"  [orange3]⚠[/] [dim]{relativePath}[/]: Remote mismatch");
                        }
                    }
                    else
                    {
                        lock (lockObject)
                        {
                            warnings++;
                        }
                        AnsiConsole.MarkupLine($"  [red]✗[/] [dim]{relativePath}[/]: Directory exists but is not a git repository");
                    }
                    return;
                }

                // Repository needs to be cloned
                lock (lockObject)
                {
                    cloned++;
                }

                if (dryRun)
                {
                    progressTask.Description = $"[cyan]{folderName}[/]: Would clone [dim]{relativePath}[/]...";
                    AnsiConsole.MarkupLine($"  [blue]→[/] [dim]{relativePath}[/]: Would clone from {repoInfo.Remote}");
                }
                else
                {
                    // Ensure parent directory exists
                    var parentDir = Path.GetDirectoryName(fullPath);
                    if (!string.IsNullOrEmpty(parentDir) && !Directory.Exists(parentDir))
                    {
                        try
                        {
                            Directory.CreateDirectory(parentDir);
                        }
                        catch (Exception ex)
                        {
                            AnsiConsole.MarkupLine($"  [red]✗[/] [dim]{relativePath}[/]: Could not create parent directory: {ex.Message}");
                            return;
                        }
                    }

                    // Clone the repository asynchronously with status updates
                    progressTask.Description = $"[cyan]{folderName}[/]: Cloning [dim]{relativePath}[/]...";

                    var (cloneSuccess, cloneOutput) = await Task.Run(() => ExecuteCommand("git", $"clone \"{repoInfo.Remote}\" \"{fullPath}\""));
                    if (!cloneSuccess)
                    {
                        AnsiConsole.MarkupLine($"  [red]✗[/] [dim]{relativePath}[/]: Failed to clone - {cloneOutput}");
                        return;
                    }

                    AnsiConsole.MarkupLine($"  [green]✓[/] [dim]{relativePath}[/]: Cloned successfully");

                    // Checkout the correct branch if needed
                    progressTask.Description = $"[cyan]{folderName}[/]: Setting up [dim]{relativePath}[/]...";

                    var currentBranch = await Task.Run(() => GetCurrentBranch(fullPath));
                    if (!string.IsNullOrEmpty(currentBranch) && currentBranch != repoInfo.Branch)
                    {
                        var (checkoutSuccess, checkoutOutput) = await Task.Run(() => ExecuteCommand("git", $"checkout {repoInfo.Branch}", fullPath));
                        if (!checkoutSuccess)
                        {
                            // Try to create and checkout the branch from origin
                            var (createSuccess, createOutput) = await Task.Run(() => ExecuteCommand("git", $"checkout -b {repoInfo.Branch} origin/{repoInfo.Branch}", fullPath));
                            if (!createSuccess)
                            {
                                lock (lockObject)
                                {
                                    warnings++;
                                }
                                AnsiConsole.MarkupLine($"  [orange3]⚠[/] [dim]{relativePath}[/]: Could not checkout branch '{repoInfo.Branch}'");
                            }
                        }
                    }
                }
            }
            finally
            {
                semaphore.Release();
            }
        });

        await Task.WhenAll(tasks);
        return (processed, cloned, warnings);
    }

    // Multi-threaded restore repositories with minimal output (fallback)
    static async Task<(int processed, int cloned, int warnings)> RestoreRepositoriesSimplifiedAsync(string baseFolder, string folderName, Dictionary<string, RepositoryInfo> repositories, bool dryRun)
    {
        const int maxRestoreParallelism = 3; // Limit parallel restore operations (git clone is I/O intensive)
        var targetFolder = Path.Combine(baseFolder, folderName);
        var processed = 0;
        var cloned = 0;
        var warnings = 0;

        AnsiConsole.MarkupLine($"[cyan]📂 {folderName}[/]: {repositories.Count} repositories");

        // Ensure target folder exists
        if (!Directory.Exists(targetFolder) && !dryRun)
        {
            try
            {
                Directory.CreateDirectory(targetFolder);
            }
            catch (Exception ex)
            {
                AnsiConsole.MarkupLine($"  [red]✗[/] Could not create directory '{targetFolder}': {ex.Message}");
                return (0, 0, 0);
            }
        }

        var semaphore = new SemaphoreSlim(maxRestoreParallelism, maxRestoreParallelism);
        var lockObject = new object();

        var tasks = repositories.Select(async repo =>
        {
            await semaphore.WaitAsync();
            try
            {
                var relativePath = repo.Key;
                var repoInfo = repo.Value;
                var fullPath = Path.Combine(targetFolder, relativePath);

                lock (lockObject)
                {
                    processed++;
                }

                // Check if repository already exists
                if (Directory.Exists(fullPath))
                {
                    if (Directory.Exists(Path.Combine(fullPath, ".git")))
                    {
                        // Run git commands asynchronously
                        var branchTask = Task.Run(() => GetCurrentBranch(fullPath));
                        var remoteTask = Task.Run(() => ExecuteGitCommand(fullPath, "remote get-url origin"));

                        await Task.WhenAll(branchTask, remoteTask);

                        var currentBranch = branchTask.Result;
                        var currentRemote = remoteTask.Result;

                        if (!string.IsNullOrEmpty(currentBranch) && currentBranch != repoInfo.Branch)
                        {
                            lock (lockObject)
                            {
                                warnings++;
                            }
                            AnsiConsole.MarkupLine($"  [orange3]⚠[/] [dim]{relativePath}[/]: Branch mismatch ([yellow]{currentBranch}[/] → [cyan]{repoInfo.Branch}[/])");
                        }

                        if (!string.IsNullOrEmpty(currentRemote) && currentRemote != repoInfo.Remote)
                        {
                            lock (lockObject)
                            {
                                warnings++;
                            }
                            AnsiConsole.MarkupLine($"  [orange3]⚠[/] [dim]{relativePath}[/]: Remote mismatch");
                        }
                    }
                    else
                    {
                        lock (lockObject)
                        {
                            warnings++;
                        }
                        AnsiConsole.MarkupLine($"  [red]✗[/] [dim]{relativePath}[/]: Directory exists but is not a git repository");
                    }
                    return;
                }

                // Repository needs to be cloned
                lock (lockObject)
                {
                    cloned++;
                }

                if (dryRun)
                {
                    AnsiConsole.MarkupLine($"  [blue]→[/] [dim]{relativePath}[/]: Would clone from {repoInfo.Remote}");
                }
                else
                {
                    // Ensure parent directory exists
                    var parentDir = Path.GetDirectoryName(fullPath);
                    if (!string.IsNullOrEmpty(parentDir) && !Directory.Exists(parentDir))
                    {
                        try
                        {
                            Directory.CreateDirectory(parentDir);
                        }
                        catch (Exception ex)
                        {
                            AnsiConsole.MarkupLine($"  [red]✗[/] [dim]{relativePath}[/]: Could not create parent directory: {ex.Message}");
                            return;
                        }
                    }

                    // Clone the repository asynchronously
                    var (cloneSuccess, cloneOutput) = await Task.Run(() => ExecuteCommand("git", $"clone \"{repoInfo.Remote}\" \"{fullPath}\""));
                    if (!cloneSuccess)
                    {
                        AnsiConsole.MarkupLine($"  [red]✗[/] [dim]{relativePath}[/]: Failed to clone - {cloneOutput}");
                        return;
                    }

                    AnsiConsole.MarkupLine($"  [green]✓[/] [dim]{relativePath}[/]: Cloned successfully");

                    // Checkout the correct branch if needed
                    var currentBranch = await Task.Run(() => GetCurrentBranch(fullPath));
                    if (!string.IsNullOrEmpty(currentBranch) && currentBranch != repoInfo.Branch)
                    {
                        var (checkoutSuccess, checkoutOutput) = await Task.Run(() => ExecuteCommand("git", $"checkout {repoInfo.Branch}", fullPath));
                        if (!checkoutSuccess)
                        {
                            // Try to create and checkout the branch from origin
                            var (createSuccess, createOutput) = await Task.Run(() => ExecuteCommand("git", $"checkout -b {repoInfo.Branch} origin/{repoInfo.Branch}", fullPath));
                            if (!createSuccess)
                            {
                                lock (lockObject)
                                {
                                    warnings++;
                                }
                                AnsiConsole.MarkupLine($"  [orange3]⚠[/] [dim]{relativePath}[/]: Could not checkout branch '{repoInfo.Branch}'");
                            }
                        }
                    }
                }
            }
            finally
            {
                semaphore.Release();
            }
        });

        await Task.WhenAll(tasks);
        return (processed, cloned, warnings);
    }

    // Legacy synchronous version for compatibility
    static (int processed, int cloned, int warnings) RestoreRepositoriesSimplified(string baseFolder, string folderName, Dictionary<string, RepositoryInfo> repositories, bool dryRun)
    {
        return RestoreRepositoriesSimplifiedAsync(baseFolder, folderName, repositories, dryRun).GetAwaiter().GetResult();
    }

    // Scan for repositories in the dev folder (multi-threaded)
    static async Task ScanForRepositoriesAsync(string devFolder, Dictionary<string, Dictionary<string, RepositoryInfo>> repoInfo)
    {
        const int maxParallelism = 4; // Limit parallel folder scanning

        try
        {
            var subdirectories = Directory.GetDirectories(devFolder);
            var semaphore = new SemaphoreSlim(maxParallelism, maxParallelism);
            var lockObject = new object();

            var tasks = subdirectories.Select(async subdir =>
            {
                await semaphore.WaitAsync();
                try
                {
                    var folderName = Path.GetFileName(subdir);
                    var folderRepoInfo = await GetRepoInfoAsync(devFolder, folderName);

                    lock (lockObject)
                    {
                        if (folderRepoInfo.Count > 0)
                        {
                            repoInfo[folderName] = folderRepoInfo;
                        }
                    }
                }
                finally
                {
                    semaphore.Release();
                }
            });

            await Task.WhenAll(tasks);
        }
        catch (Exception ex)
        {
            AnsiConsole.MarkupLine($"[red]✗[/] Error scanning directory '{devFolder}': {ex.Message}");
        }
    }

    // Legacy synchronous version for compatibility
    static void ScanForRepositories(string devFolder, Dictionary<string, Dictionary<string, RepositoryInfo>> repoInfo)
    {
        ScanForRepositoriesAsync(devFolder, repoInfo).GetAwaiter().GetResult();
    }

    // Get repository information for a folder (multi-threaded)
    static async Task<Dictionary<string, RepositoryInfo>> GetRepoInfoAsync(string baseFolder, string folderName)
    {
        const int maxRepoParallelism = 8; // Limit parallel repository scanning within a folder
        var result = new Dictionary<string, RepositoryInfo>();
        var fullFolderPath = Path.Combine(baseFolder, folderName);

        if (!Directory.Exists(fullFolderPath))
        {
            return result;
        }

        try
        {
            var directories = Directory.GetDirectories(fullFolderPath, "*", SearchOption.AllDirectories)
                .Where(dir => Directory.Exists(Path.Combine(dir, ".git")))
                .ToList();

            var foundCount = 0;
            var skippedCount = 0;
            var semaphore = new SemaphoreSlim(maxRepoParallelism, maxRepoParallelism);
            var lockObject = new object();

            var tasks = directories.Select(async directory =>
            {
                await semaphore.WaitAsync();
                try
                {
                    var relativePath = Path.GetRelativePath(fullFolderPath, directory);

                    // Run git commands asynchronously
                    var branchTask = Task.Run(() => GetCurrentBranch(directory));
                    var remoteTask = Task.Run(() => ExecuteGitCommand(directory, "remote get-url origin"));

                    await Task.WhenAll(branchTask, remoteTask);

                    var gitBranch = branchTask.Result;
                    var gitRemote = remoteTask.Result;

                    if (string.IsNullOrEmpty(gitRemote))
                    {
                        lock (lockObject)
                        {
                            skippedCount++;
                        }
                        return;
                    }

                    var repoInfo = new RepositoryInfo
                    {
                        Branch = gitBranch,
                        Remote = gitRemote
                    };

                    lock (lockObject)
                    {
                        result[relativePath] = repoInfo;
                        foundCount++;
                    }
                }
                catch (Exception)
                {
                    lock (lockObject)
                    {
                        skippedCount++;
                    }
                }
                finally
                {
                    semaphore.Release();
                }
            });

            await Task.WhenAll(tasks);

            if (foundCount > 0 || skippedCount > 0)
            {
                var status = foundCount > 0 ? $"[green]{foundCount} found[/]" : "";
                var skipped = skippedCount > 0 ? $"[yellow]{skippedCount} skipped[/]" : "";
                var combined = string.Join(", ", new[] { status, skipped }.Where(s => !string.IsNullOrEmpty(s)));
                AnsiConsole.MarkupLine($"  [cyan]{folderName}[/]: {combined}");
            }
        }
        catch (Exception ex)
        {
            AnsiConsole.MarkupLine($"  [red]✗[/] Error scanning [cyan]{folderName}[/]: {ex.Message}");
        }

        return result;
    }

    // Legacy synchronous version for compatibility
    static void GetRepoInfo(string baseFolder, string folderName, Dictionary<string, Dictionary<string, RepositoryInfo>> repoInfo)
    {
        var result = GetRepoInfoAsync(baseFolder, folderName).GetAwaiter().GetResult();
        if (result.Count > 0)
        {
            if (!repoInfo.ContainsKey(folderName))
            {
                repoInfo[folderName] = new Dictionary<string, RepositoryInfo>();
            }
            repoInfo[folderName] = result;
        }
    }

    // Restore repositories for a folder
    static void RestoreRepositories(string baseFolder, string folderName, Dictionary<string, RepositoryInfo> repositories, bool dryRun)
    {
        var targetFolder = Path.Combine(baseFolder, folderName);

        Console.WriteLine($"Processing {folderName} folder ({repositories.Count} repositories):");

        // Ensure target folder exists
        if (!Directory.Exists(targetFolder))
        {
            Console.WriteLine($"  Creating folder: {targetFolder}");
            if (!dryRun)
            {
                try
                {
                    Directory.CreateDirectory(targetFolder);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"  ERROR: Could not create directory '{targetFolder}': {ex.Message}");
                    return;
                }
            }
        }

        foreach (var repo in repositories)
        {
            var relativePath = repo.Key;
            var repoInfo = repo.Value;
            var fullPath = Path.Combine(targetFolder, relativePath);

            Console.WriteLine($"\n  Repository: {relativePath}");
            Console.WriteLine($"    Remote: {repoInfo.Remote}");
            Console.WriteLine($"    Target Branch: {repoInfo.Branch}");

            // Check if repository already exists
            if (Directory.Exists(fullPath))
            {
                if (Directory.Exists(Path.Combine(fullPath, ".git")))
                {
                    Console.WriteLine($"    Status: Repository already exists");

                    // Check current branch
                    var currentBranch = GetCurrentBranch(fullPath);
                    if (!string.IsNullOrEmpty(currentBranch))
                    {
                        if (currentBranch != repoInfo.Branch)
                        {
                            Console.WriteLine($"    WARNING: Current branch '{currentBranch}' differs from backup branch '{repoInfo.Branch}'");
                        }
                        else
                        {
                            Console.WriteLine($"    Branch: {currentBranch} (matches backup)");
                        }
                    }
                    else
                    {
                        Console.WriteLine($"    WARNING: Could not determine current branch");
                    }

                    // Check remote URL
                    var currentRemote = ExecuteGitCommand(fullPath, "remote get-url origin");
                    if (!string.IsNullOrEmpty(currentRemote) && currentRemote != repoInfo.Remote)
                    {
                        Console.WriteLine($"    WARNING: Current remote '{currentRemote}' differs from backup remote '{repoInfo.Remote}'");
                    }
                }
                else
                {
                    Console.WriteLine($"    ERROR: Directory exists but is not a git repository");
                }
                continue;
            }

            // Clone the repository
            Console.WriteLine($"    Status: Cloning repository...");
            if (!dryRun)
            {
                // Ensure parent directory exists
                var parentDir = Path.GetDirectoryName(fullPath);
                if (!string.IsNullOrEmpty(parentDir) && !Directory.Exists(parentDir))
                {
                    try
                    {
                        Directory.CreateDirectory(parentDir);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"    ERROR: Could not create parent directory '{parentDir}': {ex.Message}");
                        continue;
                    }
                }

                // Clone the repository
                var (cloneSuccess, cloneOutput) = ExecuteCommand("git", $"clone \"{repoInfo.Remote}\" \"{fullPath}\"");
                if (!cloneSuccess)
                {
                    Console.WriteLine($"    ERROR: Failed to clone repository: {cloneOutput}");
                    continue;
                }

                Console.WriteLine($"    Status: Successfully cloned");

                // Checkout the correct branch if it's not the default
                var currentBranch = GetCurrentBranch(fullPath);
                if (!string.IsNullOrEmpty(currentBranch) && currentBranch != repoInfo.Branch)
                {
                    Console.WriteLine($"    Status: Checking out branch '{repoInfo.Branch}'...");
                    var (checkoutSuccess, checkoutOutput) = ExecuteCommand("git", $"checkout {repoInfo.Branch}", fullPath);
                    if (!checkoutSuccess)
                    {
                        // Try to create and checkout the branch from origin
                        var (createSuccess, createOutput) = ExecuteCommand("git", $"checkout -b {repoInfo.Branch} origin/{repoInfo.Branch}", fullPath);
                        if (!createSuccess)
                        {
                            Console.WriteLine($"    WARNING: Could not checkout branch '{repoInfo.Branch}': {checkoutOutput}");
                        }
                        else
                        {
                            Console.WriteLine($"    Status: Successfully checked out branch '{repoInfo.Branch}'");
                        }
                    }
                    else
                    {
                        Console.WriteLine($"    Status: Successfully checked out branch '{repoInfo.Branch}'");
                    }
                }
            }
            else
            {
                Console.WriteLine($"    Status: Would clone from {repoInfo.Remote}");
                Console.WriteLine($"    Status: Would checkout branch '{repoInfo.Branch}'");
            }
        }
    }

    // Execute git commands
    static string ExecuteGitCommand(string workingDirectory, string arguments)
    {
        try
        {
            var processInfo = new ProcessStartInfo
            {
                FileName = "git",
                Arguments = arguments,
                WorkingDirectory = workingDirectory,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };

            using var process = Process.Start(processInfo);
            if (process != null)
            {
                process.WaitForExit();
                if (process.ExitCode == 0)
                {
                    return process.StandardOutput.ReadToEnd().Trim();
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"Error executing git command '{arguments}' in '{workingDirectory}': {ex.Message}");
        }
        return "";
    }

    // Execute system commands
    static (bool success, string output) ExecuteCommand(string fileName, string arguments, string workingDirectory = "")
    {
        try
        {
            var processInfo = new ProcessStartInfo
            {
                FileName = fileName,
                Arguments = arguments,
                WorkingDirectory = string.IsNullOrEmpty(workingDirectory) ? Environment.CurrentDirectory : workingDirectory,
                RedirectStandardOutput = true,
                RedirectStandardError = true,
                UseShellExecute = false,
                CreateNoWindow = true
            };

            using var process = Process.Start(processInfo);
            if (process != null)
            {
                process.WaitForExit();
                var output = process.StandardOutput.ReadToEnd().Trim();
                var error = process.StandardError.ReadToEnd().Trim();

                if (process.ExitCode == 0)
                {
                    return (true, output);
                }
                else
                {
                    return (false, !string.IsNullOrEmpty(error) ? error : output);
                }
            }
        }
        catch (Exception ex)
        {
            return (false, $"Exception: {ex.Message}");
        }
        return (false, "Unknown error");
    }

    // Get current branch name
    static string GetCurrentBranch(string workingDirectory)
    {
        var branch = ExecuteGitCommand(workingDirectory, "rev-parse --abbrev-ref HEAD");

        // If we get "HEAD" (detached state), try to get a meaningful branch name
        if (branch == "HEAD")
        {
            // Try to get the default branch from remote
            var defaultBranch = ExecuteGitCommand(workingDirectory, "symbolic-ref refs/remotes/origin/HEAD");
            if (!string.IsNullOrEmpty(defaultBranch))
            {
                // Extract branch name from refs/remotes/origin/main format
                var parts = defaultBranch.Split('/');
                if (parts.Length > 0)
                {
                    return parts[parts.Length - 1];
                }
            }

            // Fallback to main/master
            var remoteBranches = ExecuteGitCommand(workingDirectory, "branch -r");
            if (remoteBranches.Contains("origin/main"))
                return "main";
            if (remoteBranches.Contains("origin/master"))
                return "master";

            // Last resort: return current commit hash
            var commit = ExecuteGitCommand(workingDirectory, "rev-parse --short HEAD");
            return !string.IsNullOrEmpty(commit) ? commit : "main";
        }

        return !string.IsNullOrEmpty(branch) ? branch : "main";
    }
}

// Repository information structure
public class RepositoryInfo
{
    public string Branch { get; set; } = "";
    public string Remote { get; set; } = "";
}

// Repository location for diff results
public class RepoLocation
{
    public string Folder { get; set; } = "";
    public string Path { get; set; } = "";
    public RepositoryInfo Info { get; set; } = new RepositoryInfo();
}

// Diff result structure
public class DiffResult
{
    public List<RepoLocation> NewlyAdded { get; set; } = new List<RepoLocation>();
    public List<RepoLocation> Missing { get; set; } = new List<RepoLocation>();
}

// Thread-safe status tracker for concurrent operations
public class ConcurrentStatus
{
    private readonly object _lock = new object();
    private string _currentStatus = "";
    private bool _isCompleted = false;

    public void UpdateStatus(string status)
    {
        lock (_lock)
        {
            _currentStatus = status;
        }
    }

    public string GetCurrentStatus()
    {
        lock (_lock)
        {
            return _currentStatus;
        }
    }

    public void SetCompleted()
    {
        lock (_lock)
        {
            _isCompleted = true;
        }
    }

    public bool IsCompleted
    {
        get
        {
            lock (_lock)
            {
                return _isCompleted;
            }
        }
    }
}