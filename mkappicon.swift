import AppKit
let s: CGFloat = 1024
let img = NSImage(size: NSSize(width: s, height: s))
img.lockFocus()
let ctx = NSGraphicsContext.current!.cgContext
ctx.clear(CGRect(x: 0, y: 0, width: s, height: s))
// macOS squircle-ish rounded rect, continuous corners approximated
let inset: CGFloat = s*0.085
let r = NSRect(x: inset, y: inset, width: s-2*inset, height: s-2*inset)
let sq = NSBezierPath(roundedRect: r, xRadius: (s-2*inset)*0.235, yRadius: (s-2*inset)*0.235)
NSColor(calibratedRed: 0.106, green: 0.455, blue: 0.914, alpha: 1).setFill()
sq.fill()
NSColor(calibratedRed: 1, green: 0.76, blue: 0.03, alpha: 1).setFill()
NSBezierPath(ovalIn: NSRect(x: s*0.32, y: s*0.32, width: s*0.36, height: s*0.36)).fill()
img.unlockFocus()
let rep = NSBitmapImageRep(data: img.tiffRepresentation!)!
try! rep.representation(using: .png, properties: [:])!.write(to: URL(fileURLWithPath: "/tmp/badge_demo/appicon.png"))
print("appicon written")
