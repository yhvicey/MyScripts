function NewStrongPassword(
    [int]$Length = 32,
    [switch]$WriteToConsole = $false,
    [switch]$NoSpecialCharacters = $false
) {
    if ($Length -lt 16) {
        Write-Error "Length must be longer than 16.";
        return;
    }

    $numberCharacters = [int][char]'0' .. [int][char]'9' | ForEach-Object { [char]$_; };
    $lowerCharacters = [int][char]'a' .. [int][char]'z' | ForEach-Object { [char]$_; };
    $upperCharacters = [int][char]'A' .. [int][char]'Z' | ForEach-Object { [char]$_; };
    $specialCharacters = ("!", "`"", "#", "`$", "%", "&", "'", "(", ")", "*", "+", ",", "-", ".", "/", ":", ";", "<", "=", ">", "?", "@", "[", "\", "]", "^", "_", "``", "{", "|", "}", "~")

    function GetRandom ($minimum = 0.00, $maximum = 1.00) {
        return Get-Random -Minimum $minimum -Maximum $maximum;
    }

    $script:numberCharCount = 0;
    $script:lowerCharCount = 0;
    $script:upperCharCount = 0;
    $script:specialCharCount = 0;

    function PickNumberCharacter {
        $index = [int]((GetRandom) * ($numberCharacters.Length - 1));
        return [char]$numberCharacters[$index];
    }

    function PickLowerCharacter {
        $index = [int]((GetRandom) * ($lowerCharacters.Length - 1));
        return [char]$lowerCharacters[$index];
    }

    function PickUpperCharacter {
        $index = [int]((GetRandom) * ($upperCharacters.Length - 1));
        return [char]$upperCharacters[$index];
    }

    function PickSpecialCharacter {
        $index = [int]((GetRandom) * ($specialCharacters.Length - 1));
        return [char]$specialCharacters[$index];
    }

    function PickCharacter($range1 = 0.25, $range2 = 0.25, $range3 = 0.25, $range4 = 0.25) {
        $max = $range1 + $range2 + $range3 + $range4;
        $p = GetRandom -Maximum $max;
        if ($p -lt $range1) {
            $script:numberCharCount++;
            return PickNumberCharacter;
        }
        elseif ($p -lt ($range1 + $range2)) {
            $script:lowerCharCount++;
            return PickLowerCharacter;
        }
        elseif ($p -lt ($range1 + $range2 + $range3)) {
            $script:upperCharCount++;
            return PickUpperCharacter;
        }
        else {
            $script:specialCharCount++;
            return PickSpecialCharacter;
        }
    }

    $builder = New-Object System.Text.StringBuilder;
    for ($i = $0; $i -lt $Length; $i++) {
        $numberCharRange = $Length - $script:numberCharCount;
        $lowerCharRange = $Length - $script:lowerCharCount;
        $upperCharRange = $Length - $script:upperCharCount;
        if ($NoSpecialCharacters) {
            $specialCharRange = 0;
        }
        else {
            $specialCharRange = $Length - $script:specialCharCount;
        }
        [void]$builder.Append((PickCharacter -range1 $numberCharRange -range2 $lowerCharRange -range3 $upperCharRange -range4 $specialCharRange));
    }

    if ($script:numberCharCount -eq 0) {
        Write-Warning "Warning: No number character is picked for generated password.";
    }
    if ($script:lowerCharCount -eq 0) {
        Write-Warning "Warning: No lower character is picked for generated password.";
    }
    if ($script:upperCharCount -eq 0) {
        Write-Warning "Warning: No upper character is picked for generated password.";
    }
    if ($script:specialCharCount -eq 0) {
        Write-Warning "Warning: No special character is picked for generated password.";
    }

    if ($WriteToConsole) {
        Write-Host $builder.ToString();
    }
    else {
        $builder.ToString() | Set-Clipboard;
        Write-Host "Generated password already set to clipboard.";
    }
}