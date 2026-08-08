from pathlib import Path

from PIL import Image, ImageDraw


BACKGROUND = "#1C1814"
PARCHMENT = "#D4C5A9"
GOLD = "#C7A34F"
ORANGE = "#FF6B35"
INK = "#241E1A"


def scale_points(points, size):
    return [(round(x * size), round(y * size)) for x, y in points]


def render_icon(size, *, maskable=False):
    render_size = size * 4
    image = Image.new("RGB", (render_size, render_size), BACKGROUND)
    draw = ImageDraw.Draw(image)

    inset = 0.17 if maskable else 0.1
    left = inset
    right = 1 - inset
    top = inset
    bottom = 1 - inset

    straw_width = max(4, round(render_size * 0.045))
    draw.line(
        scale_points(
            [
                (left + (right - left) * 0.68, top),
                (left + (right - left) * 0.55, top + (bottom - top) * 0.38),
            ],
            render_size,
        ),
        fill=GOLD,
        width=straw_width,
    )

    glass = scale_points(
        [
            (left + (right - left) * 0.12, top + (bottom - top) * 0.2),
            (left + (right - left) * 0.88, top + (bottom - top) * 0.2),
            (left + (right - left) * 0.74, bottom),
            (left + (right - left) * 0.26, bottom),
        ],
        render_size,
    )
    liquid = scale_points(
        [
            (left + (right - left) * 0.18, top + (bottom - top) * 0.44),
            (left + (right - left) * 0.82, top + (bottom - top) * 0.44),
            (left + (right - left) * 0.74, bottom),
            (left + (right - left) * 0.26, bottom),
        ],
        render_size,
    )
    draw.polygon(glass, fill=INK)
    draw.polygon(liquid, fill=ORANGE)
    draw.line(
        glass + [glass[0]],
        fill=PARCHMENT,
        width=max(5, round(render_size * 0.045)),
        joint="curve",
    )

    die_size = round(render_size * (0.22 if maskable else 0.25))
    die = Image.new("RGBA", (die_size, die_size), (0, 0, 0, 0))
    die_draw = ImageDraw.Draw(die)
    radius = round(die_size * 0.16)
    die_draw.rounded_rectangle(
        (0, 0, die_size - 1, die_size - 1),
        radius=radius,
        fill=PARCHMENT,
    )
    pip_radius = max(2, round(die_size * 0.065))
    for x, y in ((0.3, 0.3), (0.5, 0.5), (0.7, 0.7)):
        center_x = round(die_size * x)
        center_y = round(die_size * y)
        die_draw.ellipse(
            (
                center_x - pip_radius,
                center_y - pip_radius,
                center_x + pip_radius,
                center_y + pip_radius,
            ),
            fill=INK,
        )
    die = die.rotate(-10, resample=Image.Resampling.BICUBIC, expand=True)
    image.paste(
        die,
        (
            (render_size - die.width) // 2,
            round(render_size * (top + (bottom - top) * 0.5)),
        ),
        die,
    )

    return image.resize((size, size), Image.Resampling.LANCZOS)


def main():
    web_directory = Path("web")
    icon_directory = web_directory / "icons"
    icon_directory.mkdir(parents=True, exist_ok=True)

    render_icon(192).save(icon_directory / "Icon-192.png")
    render_icon(512).save(icon_directory / "Icon-512.png")
    render_icon(192, maskable=True).save(icon_directory / "Icon-maskable-192.png")
    render_icon(512, maskable=True).save(icon_directory / "Icon-maskable-512.png")
    render_icon(64).save(web_directory / "favicon.png")


if __name__ == "__main__":
    main()