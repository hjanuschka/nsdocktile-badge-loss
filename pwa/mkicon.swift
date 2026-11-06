import AppKit
func makeIcon(_ size: Int, _ path: String) {
  let s = CGFloat(size)
  let img = NSImage(size: NSSize(width: s, height: s))
  img.lockFocus()
  NSColor(calibratedRed: 0.10, green: 0.45, blue: 0.91, alpha: 1).setFill()
  let bg = NSBezierPath(roundedRect: NSRect(x: 0, y: 0, width: s, height: s), xRadius: s*0.22, yRadius: s*0.22)
  bg.fill()
  NSColor(calibratedRed: 1, green: 0.76, blue: 0.03, alpha: 1).setFill()
  NSBezierPath(ovalIn: NSRect(x: s*0.22, y: s*0.22, width: s*0.56, height: s*0.56)).fill()
  img.unlockFocus()
  let tiff = img.tiffRepresentation!
  let rep = NSBitmapImageRep(data: tiff)!
  let png = rep.representation(using: .png, properties: [:])!
  try! png.write(to: URL(fileURLWithPath: path))
}
makeIcon(192, "/tmp/badge_demo/pwa/icon-192.png")
makeIcon(512, "/tmp/badge_demo/pwa/icon-512.png")
print("icons written")
