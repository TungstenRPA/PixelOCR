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

# 4 inputs
# - image: bitmap to OCR
# - font: bitmap of font - no whitespace above, below or left of characters. 1 column of Whitespace between characters and after last character
# - characters: the characters of the font in order
# - character widths:  These could be calculated but it would slow down the algorithm.
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
            $Pixel = $bitmap.GetPixel($x,$y)
            if ($Pixel.Name -eq "ffffffff") { $pcount++}   #counting white pixels!
        }
        if  ($pcount -lt $bitmap.Width) {return $startY}  # this horizontal line contains pixels - it is not blank
        $startY++ # this was a blank horizontal line. look in next
    }
    return -1 # the rest of the image was blank
}
Function Get-OCR([string]$ImageFileName, [string]$FontFileName, [string]$Characters, [string]$CharWidths) {
    $font = New-Object System.Drawing.Bitmap $FontFileName 
    $image = New-Object System.Drawing.Bitmap $ImageFileName 
    $imageY=(Get-NextRow $image 0) # skip white space above text
    $imageX=(Get-NextColumn $image $imageX $imageY $font.Height $true) # skip white space left of the text
    $OCR=""
    while(($imageX -ne -1) -and ($imageX -lt $image.Width)){ # loop through each character in image
        $fontX=0
        $fontIndex =0
        $CharWidth=0 # we need to define this here, so we can increment on the image after a match
        :matchchars foreach ($CharWidthSt in $CharWidths.Split()){ # loop through font finding a match
            $CharWidth=[int]$CharWidthSt
            $match = $true
            :matchpixels for ($x=0; $x -lt $Charwidth; $x++ ) { # loop through pixels until mismatch found
                for ($y=0; $y -lt $font.Height; $y++ ) {
                    $Pixel = $image.GetPixel($imageX+$x, $imageY+ $y)
                    $FontPixel=$font.Getpixel($x+$fontX,$y)
                    if ($Pixel.Name -ne $FontPixel.Name) {
                        $match = $false
                        break matchpixels # pixel mismatch, stop matching this character
                    }
                }
            }
            if ($match) {break matchchars} # successful match on all pixels
            $fontx+=$charwidth+1 # try next character
            $fontIndex++
        }
        if (-not $match) {
            Throw "Failed to perform OCR. Unknown character found at ($imageX,$imageY)."
        }
        $OCR=$OCR+$Characters.substring($fontIndex,1)
        # Write-Host "$OCR" # log OCR 
        $imageX=(Get-NextColumn $image ($imageX+$CharWidth) $imageY $font.Height $true) # skip white space left of the text
    }
    $font.Dispose()
    $image.Dispose()
    return $OCR
}
Write-Host "PixelOCR"
$truth="11764379-40892883/1176"
$z = (Get-OCR ".\image.png" ".\font.png" "0123456789-/" "5 3 5 5 5 5 5 5 5 5 2 4")
Write-Host "OCR = $z"
if ($truth -eq $z) {Write-Host "success"} else {Throw "OCR failed on $truth"}
