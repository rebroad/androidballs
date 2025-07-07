import sys
from PIL import Image, ImageDraw, ImageFont

# Icon parameters
size = 512
bg_color = (100, 149, 237, 255)  # Cornflower blue
text = "SDL"
text_color = (255, 255, 255, 255)

# Create image
img = Image.new("RGBA", (size, size), bg_color)
draw = ImageDraw.Draw(img)

# Draw a white circle for a modern look
circle_margin = 32
draw.ellipse([
    circle_margin, circle_margin,
    size - circle_margin, size - circle_margin
], fill=(255, 255, 255, 255))

# Draw blue circle inside
inner_margin = 64
draw.ellipse([
    inner_margin, inner_margin,
    size - inner_margin, size - inner_margin
], fill=bg_color)

# Load a font
try:
    font = ImageFont.truetype("DejaVuSans-Bold.ttf", 200)
except IOError:
    font = ImageFont.load_default()

# Center the text using textbbox
bbox = draw.textbbox((0, 0), text, font=font)
w = bbox[2] - bbox[0]
h = bbox[3] - bbox[1]
text_x = (size - w) // 2
text_y = (size - h) // 2

# Draw the text
draw.text((text_x, text_y), text, font=font, fill=text_color)

# Save the icon
img.save("app_icon.png")
print("Icon generated: app_icon.png") 