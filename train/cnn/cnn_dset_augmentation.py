import os
from PIL import Image
from PIL import ImageEnhance 

#####################
"""Adjust PATH"""
#####################
file_path = 'YOUR FILE PATH'

file_names = os.listdir(file_path)


# Augmentation with adjusting brightness
for i in file_names:
    origin_image_path = file_path + '/' + i
    image = Image.open(origin_image_path)

    enhancer = ImageEnhance.Brightness(image)
    enhancer.enhance(1.2).save(file_path + 'Bup_' + i)

    enhancer.enhance(0.7).save(file_path + 'Bdown_' + i)

