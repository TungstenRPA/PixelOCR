# PixelOCR
Simple Pixel-based OCR for black bitmap fonts on white background.
This takes 4 inputs.
- a B&W sample image, that MUST contain 100% white pixels above and to left of characters.
- A B&W font in png format.  ![image](font.png)
    - no white pixels above nor below.
    - one white pixel column between characters.
    - one white pixel column at right edge of image.
- the characters of the font **0123456789-/**
- the widths of each character in the font "5 3 5 5 5 5 5 5 5 5 2 4"

This was built using this sample image and returned the value "11764379-40892883/1176"
![image](image.png)
