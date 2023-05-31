Add-Type -AssemblyName System.Drawing
Write-Output "PixelOCR!"

Function Get-OCR([string]$FileName) {
    $font = New-Object System.Drawing.Bitmap ".\font.png" 
    Write-Host "width=($font.Width)"
    # $font = [System.Drawing.Bitmap]::FromFile(".\font.png")
    $image = New-Object System.Drawing.Bitmap $FileName    
    # $imagear = [System.Drawing.Bitmap]::FromFile($FileName)
    $count = 0
    for ($x=0; $x -lt $image.Width; $x++ ) {
        for ($y=0; $y -lt $image.Height; $y++ ) {
            $col = $image.GetPixel($x,$y)
            $imageCol=$font.Getpixel($x,$y)
            if ($col.R -eq $imageCol.R) {$count++}
        }
    }
    $font.Dispose()
    # $image.Dispose()
    return $count #/($image.Width*$image.Height*1.0)
}
Write-Host "Hello!"
$z = (Get-OCR ".\image.png")
Write-Host "pixels matched = $($z+1)"
