function DecryptPfxFile(
    [string]$PfxFile,
    [switch]$SkipBase64Encoding = $False
) {
    if (-not (Test-Path $PfxFile)) {
        throw "File not found"
    }

    $fileName = (Split-Path $PfxFile -Leaf).Replace(".pfx", "")

    # Convert to pem, crt and key
    try {
        openssl pkcs12 -in $PfxFile -out "$fileName.pem" -nodes
        openssl crl2pkcs7 -nocrl -certfile "$fileName.pem" | openssl pkcs7 -print_certs -out "$fileName.crt"
        openssl pkey -in "$fileName.pem" -out "$fileName.key"
    }
    catch {
        if (Test-Path "$fileName.pem") {
            Remove-Item "$fileName.pem"
        }
        if (Test-Path "$fileName.crt") {
            Remove-Item "$fileName.crt"
        }
        if (Test-Path "$fileName.key") {
            Remove-Item "$fileName.key"
        }
    }

    if (-not $SkipBase64Encoding) {
        $crtBase64Encoded = Get-Content -Raw "$fileName.crt" | EncodeToBase64
        $keyBase64Encoded = Get-Content -Raw "$fileName.key" | EncodeToBase64
        try {
            Set-Content -Value $crtBase64Encoded -Path "$fileName.crt.b64"
            Set-Content -Value $keyBase64Encoded -Path "$fileName.key.b64"
        }
        catch {
            if (Test-Path "$fileName.crt.b64") {
                Remove-Item "$fileName.crt.b64"
            }
            if (Test-Path "$fileName.key.b64") {
                Remove-Item "$fileName.key.b64"
            }
        }
    }
}