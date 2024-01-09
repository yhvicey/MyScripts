function StartProcessOrPath {
    if ($args.Count -eq 0) {
        Start-Process -FilePath .;
    }
    else {
        Start-Process -FilePath $args[0] $args;
    }
}
Set-Alias "s" "StartProcessOrPath";

function StartToolsBinFolder {
    Start-Process $global:ToolsBinFolder
}
Set-Alias "sbin" "StartToolsBinFolder";
