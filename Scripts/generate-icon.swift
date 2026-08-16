// Generates AppIcon.icns: red-gradient squircle with a cloud + note glyph.
// Run: swift Scripts/generate-icon.swift
import AppKit

func drawIcon(size: CGFloat) -> NSImage {
    let image = NSImage(size: NSSize(width: size, height: size))
    image.lockFocus()
    guard let ctx = NSGraphicsContext.current?.cgContext else {
        image.unlockFocus()
        return image
    }

    let s = size / 1024.0

    // macOS icon grid: content squircle inset ~100/1024, radius ~185/1024
    let rect = CGRect(x: 100 * s, y: 100 * s, width: 824 * s, height: 824 * s)
    let squircle = CGPath(roundedRect: rect, cornerWidth: 185 * s, cornerHeight: 185 * s, transform: nil)

    // Shadow
    ctx.saveGState()
    ctx.setShadow(offset: CGSize(width: 0, height: -12 * s), blur: 24 * s,
                  color: NSColor.black.withAlphaComponent(0.3).cgColor)
    ctx.addPath(squircle)
    ctx.setFillColor(NSColor.white.cgColor)
    ctx.fillPath()
    ctx.restoreGState()

    // Gradient fill
    ctx.saveGState()
    ctx.addPath(squircle)
    ctx.clip()
    let colors = [
        NSColor(srgbRed: 0.976, green: 0.357, blue: 0.341, alpha: 1).cgColor,
        NSColor(srgbRed: 0.859, green: 0.157, blue: 0.184, alpha: 1).cgColor,
        NSColor(srgbRed: 0.702, green: 0.086, blue: 0.129, alpha: 1).cgColor,
    ]
    let gradient = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                              colors: colors as CFArray, locations: [0, 0.55, 1])!
    ctx.drawLinearGradient(gradient,
                           start: CGPoint(x: rect.minX, y: rect.maxY),
                           end: CGPoint(x: rect.maxX, y: rect.minY),
                           options: [])

    // Subtle highlight
    let highlight = CGGradient(colorsSpace: CGColorSpaceCreateDeviceRGB(),
                               colors: [NSColor.white.withAlphaComponent(0.22).cgColor,
                                        NSColor.white.withAlphaComponent(0).cgColor] as CFArray,
                               locations: [0, 1])!
    ctx.drawLinearGradient(highlight,
                           start: CGPoint(x: rect.midX, y: rect.maxY),
                           end: CGPoint(x: rect.midX, y: rect.midY),
                           options: [])

    // Cloud: union of circles + base, drawn in white with soft shadow
    ctx.setShadow(offset: CGSize(width: 0, height: -8 * s), blur: 30 * s,
                  color: NSColor.black.withAlphaComponent(0.25).cgColor)
    ctx.setFillColor(NSColor.white.cgColor)

    let cloud = CGMutablePath()
    // base rounded bar
    cloud.addPath(CGPath(roundedRect: CGRect(x: 250 * s, y: 330 * s, width: 530 * s, height: 190 * s),
                         cornerWidth: 95 * s, cornerHeight: 95 * s, transform: nil))
    cloud.addEllipse(in: CGRect(x: 280 * s, y: 400 * s, width: 240 * s, height: 240 * s))
    cloud.addEllipse(in: CGRect(x: 430 * s, y: 440 * s, width: 300 * s, height: 300 * s))
    ctx.addPath(cloud)
    ctx.fillPath()

    // Note on the cloud: filled note-head + stem + flag, in gradient red
    ctx.setShadow(offset: .zero, blur: 0, color: nil)
    ctx.setFillColor(NSColor(srgbRed: 0.82, green: 0.13, blue: 0.17, alpha: 1).cgColor)

    // note head (ellipse, slightly rotated)
    ctx.saveGState()
    ctx.translateBy(x: 470 * s, y: 425 * s)
    ctx.rotate(by: -0.35)
    ctx.addEllipse(in: CGRect(x: -62 * s, y: -46 * s, width: 124 * s, height: 92 * s))
    ctx.fillPath()
    ctx.restoreGState()

    // stem
    ctx.addPath(CGPath(roundedRect: CGRect(x: 508 * s, y: 430 * s, width: 34 * s, height: 190 * s),
                       cornerWidth: 17 * s, cornerHeight: 17 * s, transform: nil))
    ctx.fillPath()

    // flag (curve)
    let flag = CGMutablePath()
    flag.move(to: CGPoint(x: 542 * s, y: 620 * s))
    flag.addCurve(to: CGPoint(x: 660 * s, y: 520 * s),
                  control1: CGPoint(x: 620 * s, y: 610 * s),
                  control2: CGPoint(x: 660 * s, y: 575 * s))
    flag.addCurve(to: CGPoint(x: 615 * s, y: 435 * s),
                  control1: CGPoint(x: 660 * s, y: 480 * s),
                  control2: CGPoint(x: 645 * s, y: 450 * s))
    flag.addCurve(to: CGPoint(x: 640 * s, y: 530 * s),
                  control1: CGPoint(x: 638 * s, y: 470 * s),
                  control2: CGPoint(x: 645 * s, y: 505 * s))
    flag.addCurve(to: CGPoint(x: 542 * s, y: 585 * s),
                  control1: CGPoint(x: 628 * s, y: 552 * s),
                  control2: CGPoint(x: 595 * s, y: 575 * s))
    flag.closeSubpath()
    ctx.addPath(flag)
    ctx.fillPath()

    ctx.restoreGState()
    image.unlockFocus()
    return image
}

let iconsetURL = URL(fileURLWithPath: "Sources/Kumone/Resources/AppIcon.iconset")
try? FileManager.default.removeItem(at: iconsetURL)
try! FileManager.default.createDirectory(at: iconsetURL, withIntermediateDirectories: true)

let sizes: [(String, CGFloat)] = [
    ("icon_16x16", 16), ("icon_16x16@2x", 32),
    ("icon_32x32", 32), ("icon_32x32@2x", 64),
    ("icon_128x128", 128), ("icon_128x128@2x", 256),
    ("icon_256x256", 256), ("icon_256x256@2x", 512),
    ("icon_512x512", 512), ("icon_512x512@2x", 1024),
]

for (name, size) in sizes {
    let image = drawIcon(size: size)
    guard let tiff = image.tiffRepresentation,
          let rep = NSBitmapImageRep(data: tiff) else { continue }
    rep.size = NSSize(width: size, height: size)
    guard let png = rep.representation(using: .png, properties: [:]) else { continue }
    try! png.write(to: iconsetURL.appendingPathComponent("\(name).png"))
}
print("iconset written")
