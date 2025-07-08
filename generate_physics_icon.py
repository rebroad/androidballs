#!/usr/bin/env python3
"""
Generate physics demo app icons with bouncing balls design
"""

import sys
import os
from PIL import Image, ImageDraw, ImageFont
import math

def create_physics_icon(size):
    """Create a physics demo icon with bouncing balls"""
    
    # Create image with dark background
    img = Image.new("RGBA", (size, size), (30, 30, 50, 255))
    draw = ImageDraw.Draw(img)
    
    # Ball colors (vibrant colors for physics demo)
    ball_colors = [
        (255, 100, 100, 255),  # Red
        (100, 255, 100, 255),  # Green
        (100, 100, 255, 255),  # Blue
        (255, 255, 100, 255),  # Yellow
        (255, 100, 255, 255),  # Magenta
        (100, 255, 255, 255),  # Cyan
    ]
    
    # Ball positions (simulate bouncing)
    ball_positions = [
        (size * 0.3, size * 0.3, 0.15),  # Top left
        (size * 0.7, size * 0.4, 0.12),  # Top right
        (size * 0.4, size * 0.7, 0.14),  # Bottom left
        (size * 0.8, size * 0.8, 0.11),  # Bottom right
        (size * 0.5, size * 0.5, 0.13),  # Center
    ]
    
    # Draw balls with shadows
    for i, (x, y, radius_ratio) in enumerate(ball_positions):
        radius = int(size * radius_ratio)
        color = ball_colors[i % len(ball_colors)]
        
        # Draw shadow
        shadow_offset = max(2, radius // 8)
        draw.ellipse([
            x - radius + shadow_offset, 
            y - radius + shadow_offset,
            x + radius + shadow_offset, 
            y + radius + shadow_offset
        ], fill=(0, 0, 0, 100))
        
        # Draw ball
        draw.ellipse([
            x - radius, y - radius,
            x + radius, y + radius
        ], fill=color)
        
        # Add highlight
        highlight_radius = radius // 3
        highlight_offset = radius // 4
        draw.ellipse([
            x - highlight_radius + highlight_offset,
            y - highlight_radius + highlight_offset,
            x + highlight_radius + highlight_offset,
            y + highlight_radius + highlight_offset
        ], fill=(255, 255, 255, 150))
    
    return img

def generate_all_sizes():
    """Generate icons for all Android mipmap sizes"""
    
    # Android mipmap sizes
    sizes = {
        'mdpi': 48,
        'hdpi': 72,
        'xhdpi': 96,
        'xxhdpi': 144,
        'xxxhdpi': 192
    }
    
    # Create output directory
    output_dir = "icon_physics_demo_tmp"
    if not os.path.exists(output_dir):
        os.makedirs(output_dir)
    
    # Generate icons for each size
    for size_name, size in sizes.items():
        icon = create_physics_icon(size)
        filename = f"ic_launcher_{size_name}.png"
        filepath = os.path.join(output_dir, filename)
        icon.save(filepath)
        print(f"Generated: {filepath}")
    
    print(f"\nAll physics demo icons generated in '{output_dir}/'")
    print("These will be automatically copied to the Android project during build.")

if __name__ == "__main__":
    if len(sys.argv) > 1 and sys.argv[1] in ["-h", "--help"]:
        print("Generate physics demo app icons with bouncing balls design")
        print("Usage: python3 generate_physics_icon.py")
        sys.exit(0)
    
    generate_all_sizes() 