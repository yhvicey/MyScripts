param(
    [System.IO.FileInfo]$CsScript
)

& dotnet run $CsScript.FullName -- @args