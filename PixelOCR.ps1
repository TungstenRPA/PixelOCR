Add-Type -AssemblyName System.Drawing
# Pixel OCR v0.9
# Features
# - Black&White pixel fonts
# - background must be white
# - variable character width
# - Any font sizes, character set, language. Characters cannot be merged. 
# - Each character must be a single letter
# - Left-to-Right alphabet.
# - single line of text. other text lines are ignored

# 3 inputs
# - image: bitmap to OCR
# - font: bitmap of font - no whitespace above, below or left of characters. 1 column of Whitespace between characters and after last character
# - characters: the characters of the font in order
Function Get-NextColumn([System.Drawing.Bitmap]$bitmap, [int32]$startX, [int32]$startY, [int32]$fontHeight, $black) {
    #Find either the Nextcolumn containing >1 Black Pixel, or the next column containing only white pixels.
    # We need both options because we don't know character width.
    for ($x=$startX; $x -lt $bitmap.Width; $x++ ) {
        $pcount = 0
        for ($y=$startY; ($y -lt $startY+$fontHeight) -and ($y -lt $bitmap.Height) ; $y++ ) {
            $Pixel = $bitmap.GetPixel($x,$y)
            if ($Pixel.R -eq 255) {$pcount++}
        }
        if  (($pcount -lt $fontHeight) -eq $black) {return $startX}  # this vertical line contains pixels
        $startx++ # this was a blank vertical line. look in next
    }
    return -1 # the rest of the image was blank
}
Function Get-NextRow([System.Drawing.Bitmap]$bitmap, [int32]$startY) {
    #Find the next row containing >1 Black pixel. We don't need to search for white rows because we know the character height.
    $pcount = 0
    for ($y=$startY; $y -lt $bitmap.Height ; $y++ ) {
        $pcount = 0
        for ($x=0; $x -lt $bitmap.Width; $x++ ) {
            $col = $bitmap.GetPixel($x,$y)
            if ($col.R -eq 255) { $pcount++}
        }
        if  ($pcount -lt $bitmap.Width) {return $startY}  # this horizontal line contains pixels - it is not blank
        $startY++ # this was a blank horizontal line. look in next
    }
    return -1 # the rest of the image was blank
}
Function Get-OCR([string]$ImageFileName, [string]$FontFileName, [string]$Characters) {
    $font = New-Object System.Drawing.Bitmap $FontFileName 
    $image = New-Object System.Drawing.Bitmap $ImageFileName 
    $fontX=0
    $fontIndex =0
    $fontBestIndex =0
    $fontBestScore=0
    $imageY=(Get-NextRow $image 0) # skip white space above text
    $imageX=(Get-NextColumn $image $imageX $imageY $font.Height $true) # skip white space left of the text
    $OCR=""
    # loop through each character in the font
    while (($fontX -ne -1) -and ($fontX -lt $font.width)) { 
        $fontNextX = (Get-NextColumn $font ($fontX+1) 0 $font.Height $false)+1
        if ($fontnextX -eq -1) { $fontnextX = $font.width+1}
        $charWidth = $fontnextX-$fontX -1 # the width in pixels of next font character
        $pcount = 0
        for ($x=0; $x -lt $charwidth; $x++ ) {
            for ($y=0; $y -lt $font.Height; $y++ ) {
                $Pixel = $image.GetPixel($imageX+$x, $imageY+ $y)
                $FontPixel=$font.Getpixel($x+$fontX,$y)
                if ($Pixel.R -eq $FontPixel.R) {$pcount++}
            }
        }
        $pcount = $pcount/($charwidth * $font.height)  # we need to normalize the matching score to 0..1
        $ch=$Characters.substring($fontIndex,1)
        Write-Host "$ch : $pcount"
        if ($pcount -gt $fontBestScore) {
            $fontBestScore= $pcount
            $fontBestIndex = $fontindex
        }
        $fontx=$fontNextX
        $fontIndex++
        if ($fontx -ge $font.Width) {break} # we reached the end of the font
    }
    $OCRChar=$Characters.substring($fontBestIndex,1)
    $OCR+=$OCRChar
    $font.Dispose()
    $image.Dispose()
    return $OCR
}
Write-Host "PixelOCR"
$truth="11764379-40892883/1176"
$z = (Get-OCR ".\image.png" ".\font.png" "0123456789-/")
Write-Host "OCR = $z"
if ($truth -eq $z) {Write-Host "success"}
