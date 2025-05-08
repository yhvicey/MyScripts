if ($args.Count -eq 0) {
    Start-Process -FilePath .;
}
else {
    Start-Process -FilePath $args[0] $args;
}
