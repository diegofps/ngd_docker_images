#!/usr/bin/python3

from PIL import Image
import tesserwrap
import time

filepath1 = "/home/diego/Sources/demo_openalpr/datasets/tesseract/saude.png"
filepath2 = "/home/diego/Sources/demo_openalpr/datasets/tesseract/saude2.png"

start = time.monotonic()
tr = tesserwrap.Tesseract(lang="por")
print(time.monotonic() - start)

start = time.monotonic()
text1 = tr.ocr_image(Image.open(filepath1)).strip()
print(time.monotonic() - start)

start = time.monotonic()
text2 = tr.ocr_image(Image.open(filepath2)).strip()
print(time.monotonic() - start)

print(text1)
print(text2)
