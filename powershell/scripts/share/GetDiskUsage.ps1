param([string]$Directory = ".")

Get-ChildItem $Directory | ForEach-Object {
    $folder = $_;
    Get-ChildItem -r $_.FullName | Measure-Object -Property Length -Sum | Select-Object @{
        Name       = "Name";
        Expression = {
            $folder
        }
    }, @{
        Name       = "Length";
        Expression = {
            GetFileSize $_.Sum;
        }
    }, Sum
} | Sort-Object -Property Sum -Descending | Select-Object Name, Length
