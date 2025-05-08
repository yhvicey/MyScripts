param([long]$fileSize)

switch ($fileSize) {
    { $_ -gt 1tb } {
        return "{0:n2} TB" -f ($_ / 1tb);
    }
    { $_ -gt 1gb } {
        return "{0:n2} GB" -f ($_ / 1gb);
    }
    { $_ -gt 1mb } {
        return "{0:n2} MB" -f ($_ / 1mb);
    }
    { $_ -gt 1kb } {
        return "{0:n2} KB" -f ($_ / 1kb);
    }
    Default {
        return "{0:n2} B" -f $_;
    }
}