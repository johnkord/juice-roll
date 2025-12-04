#!/usr/bin/env python3
"""
Slice the abstract icons grid from juice_page-2.png into individual ROW_COL.png tiles.

The grid has 10 rows (labeled 1-9, then 0) and 6 columns (labeled 1-6).
Row labels use 1-9 for first 9 rows, then 0 for the 10th row.
"""

from PIL import Image, ImageOps
from pathlib import Path
import argparse


def find_content_bbox(img, threshold=200):
    """
    Find the bounding box of non-background content in an image.
    Assumes background is light (close to white/beige) and content is dark.
    Returns (left, top, right, bottom) or None if no content found.
    """
    # Convert to grayscale
    gray = img.convert('L')
    
    # Find pixels darker than threshold (the icon)
    width, height = gray.size
    pixels = gray.load()
    
    min_x, min_y = width, height
    max_x, max_y = 0, 0
    found = False
    
    for y in range(height):
        for x in range(width):
            if pixels[x, y] < threshold:
                found = True
                min_x = min(min_x, x)
                min_y = min(min_y, y)
                max_x = max(max_x, x)
                max_y = max(max_y, y)
    
    if not found:
        return None
    
    return (min_x, min_y, max_x + 1, max_y + 1)


def center_content(img, output_size, threshold=200, bg_color=None):
    """
    Find the content in the image and center it in a square of output_size.
    """
    bbox = find_content_bbox(img, threshold)
    
    if bbox is None:
        # No content found, just resize
        return img.resize((output_size, output_size))
    
    # Extract the content
    content = img.crop(bbox)
    cw, ch = content.size
    
    # Add some padding around the content (10% of output size)
    padding = int(output_size * 0.08)
    available = output_size - 2 * padding
    
    # Scale content to fit within available space while maintaining aspect ratio
    scale = min(available / cw, available / ch)
    new_w = int(cw * scale)
    new_h = int(ch * scale)
    
    if scale < 1:
        content = content.resize((new_w, new_h), Image.LANCZOS)
    
    # Detect background color by sampling multiple points from the original tile edges
    # Use the most common light color found
    if bg_color is None:
        pixels = img.load()
        w, h = img.size
        samples = []
        # Sample from edges (avoiding corners which might have icon content)
        for x in range(0, w, max(1, w // 10)):
            samples.append(pixels[x, 0])  # top edge
            samples.append(pixels[x, h-1])  # bottom edge
        for y in range(0, h, max(1, h // 10)):
            samples.append(pixels[0, y])  # left edge
            samples.append(pixels[w-1, y])  # right edge
        
        # Filter to only light colors (background, not icon)
        if img.mode == 'RGB':
            light_samples = [s for s in samples if sum(s) > 500]  # light colors
        elif img.mode == 'RGBA':
            light_samples = [s for s in samples if sum(s[:3]) > 500]
        else:
            light_samples = samples
        
        if light_samples:
            bg_color = max(set(light_samples), key=light_samples.count)
        else:
            bg_color = samples[0] if samples else (255, 255, 255)
    
    # Create new image with background color and paste content centered
    result = Image.new(img.mode, (output_size, output_size), bg_color)
    
    paste_x = (output_size - content.size[0]) // 2
    paste_y = (output_size - content.size[1]) // 2
    
    result.paste(content, (paste_x, paste_y))
    
    return result


def slice_grid(
    image_path: str,
    out_dir: str,
    rows: int = 10,
    cols: int = 6,
    crop_box: tuple = None,
    preview: bool = False,
    padding: tuple = (0, 0, 0, 0),
    square: bool = False,
    auto_center: bool = False,
    output_size: int = 200,
):
    """
    Slices an image into a rows×cols grid and saves tiles as ROW_COL.png.

    image_path  : path to the source PNG
    out_dir     : directory where tiles are written
    rows, cols  : how many rows/columns the grid has
    crop_box    : (left, top, right, bottom) to crop before slicing, or None for whole image
    preview     : if True, just show the crop area without saving tiles
    padding     : (left, top, right, bottom) pixels to trim from each tile's edges
    square      : if True, crop tiles to square (centered)
    auto_center : if True, detect icon content and center it automatically
    output_size : size of output square when auto_center is True
    """
    img = Image.open(image_path)
    print(f"Original image size: {img.size}")

    # Crop to grid area if specified
    if crop_box:
        grid = img.crop(crop_box)
        print(f"Cropped to: {crop_box} -> size {grid.size}")
    else:
        grid = img

    if preview:
        preview_path = Path(out_dir) / "_preview_crop.png"
        preview_path.parent.mkdir(parents=True, exist_ok=True)
        grid.save(preview_path)
        print(f"Preview saved to: {preview_path}")
        return

    gw, gh = grid.size
    out_path = Path(out_dir)
    out_path.mkdir(parents=True, exist_ok=True)

    # Row labels: 1, 2, 3, 4, 5, 6, 7, 8, 9, 0
    row_labels = [1, 2, 3, 4, 5, 6, 7, 8, 9, 0]

    for r in range(rows):
        for c in range(cols):
            # Proportional rounding so all pixels are used
            left = round(c * gw / cols)
            right = round((c + 1) * gw / cols)
            upper = round(r * gh / rows)
            lower = round((r + 1) * gh / rows)

            tile = grid.crop((left, upper, right, lower))

            # Apply inner padding (trim edges of each tile)
            tw, th = tile.size
            pad_left, pad_top, pad_right, pad_bottom = padding
            if any(padding):
                tile = tile.crop((
                    pad_left,
                    pad_top,
                    tw - pad_right,
                    th - pad_bottom
                ))

            # Make square if requested (center crop)
            if square and not auto_center:
                tw, th = tile.size
                if tw != th:
                    size = min(tw, th)
                    left_offset = (tw - size) // 2
                    top_offset = (th - size) // 2
                    tile = tile.crop((
                        left_offset,
                        top_offset,
                        left_offset + size,
                        top_offset + size
                    ))

            # Auto-center: detect the icon and center it in a uniform square
            if auto_center:
                tile = center_content(tile, output_size)

            # Use the actual row label (1-9, then 0)
            row_label = row_labels[r]
            col_label = c + 1  # Columns are 1-indexed

            filename = f"{row_label}_{col_label}.png"
            tile.save(out_path / filename)
            print(f"Saved: {filename} ({tile.size[0]}x{tile.size[1]})")

    print(f"\nDone! {rows * cols} tiles saved to {out_dir}")


def main():
    parser = argparse.ArgumentParser(
        description="Slice the abstract icons grid into ROW_COL.png tiles."
    )
    parser.add_argument(
        "image",
        nargs="?",
        default="reference/juice-oracle-images/juice_page-2.png",
        help="Path to the table image (default: reference/juice-oracle-images/juice_page-2.png)",
    )
    parser.add_argument(
        "-o",
        "--out-dir",
        default="assets/images/abstract_icons",
        help="Output directory (default: assets/images/abstract_icons)",
    )
    parser.add_argument(
        "--rows", type=int, default=10, help="Number of rows of icons (default: 10)"
    )
    parser.add_argument(
        "--cols", type=int, default=6, help="Number of columns of icons (default: 6)"
    )
    parser.add_argument(
        "--crop",
        type=str,
        default=None,
        help="Crop box as 'left,top,right,bottom' (e.g., '100,50,800,1200')",
    )
    parser.add_argument(
        "--preview",
        action="store_true",
        help="Preview the crop area without saving tiles",
    )
    parser.add_argument(
        "--padding",
        type=str,
        default="0,0,0,0",
        help="Pixels to trim from each tile as 'left,top,right,bottom' (e.g., '5,10,5,10')",
    )
    parser.add_argument(
        "--square",
        action="store_true",
        help="Crop each tile to a centered square",
    )
    parser.add_argument(
        "--auto-center",
        action="store_true",
        help="Automatically detect and center the icon content in each tile",
    )
    parser.add_argument(
        "--output-size",
        type=int,
        default=200,
        help="Size of output square when using --auto-center (default: 200)",
    )
    args = parser.parse_args()

    # Parse crop box if provided
    crop_box = None
    if args.crop:
        try:
            crop_box = tuple(int(x.strip()) for x in args.crop.split(","))
            if len(crop_box) != 4:
                raise ValueError("Crop box must have exactly 4 values")
        except ValueError as e:
            parser.error(f"Invalid crop box format: {e}")

    # Parse padding
    try:
        padding = tuple(int(x.strip()) for x in args.padding.split(","))
        if len(padding) != 4:
            raise ValueError("Padding must have exactly 4 values")
    except ValueError as e:
        parser.error(f"Invalid padding format: {e}")

    slice_grid(
        image_path=args.image,
        out_dir=args.out_dir,
        rows=args.rows,
        cols=args.cols,
        crop_box=crop_box,
        preview=args.preview,
        padding=padding,
        square=args.square,
        auto_center=args.auto_center,
        output_size=args.output_size,
    )


if __name__ == "__main__":
    main()
