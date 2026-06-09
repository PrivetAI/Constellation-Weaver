import SwiftUI

// All custom SwiftUI Shape-based icons. No SF Symbols, no emoji.

// A four-point sparkle star.
struct WeaverStarIcon: View {
    var size: CGFloat = 24
    var color: Color = WeaverTheme.textPrimary

    var body: some View {
        WeaverSparkleShape()
            .fill(color)
            .frame(width: size, height: size)
    }
}

struct WeaverSparkleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2
        let inner = r * 0.30
        // 4 long points + 4 short points = 8 vertices
        let longPts = 4
        let total = longPts * 2
        for i in 0..<total {
            let angle = (CGFloat(i) / CGFloat(total)) * 2 * .pi - .pi / 2
            let radius = (i % 2 == 0) ? r : inner
            let pt = CGPoint(x: c.x + cos(angle) * radius,
                             y: c.y + sin(angle) * radius)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}

// A small constellation glyph: dots joined by lines.
struct WeaverGlyphIcon: View {
    var size: CGFloat = 24
    var color: Color = WeaverTheme.textPrimary

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            let pts = [
                CGPoint(x: 0.15 * w, y: 0.30 * h),
                CGPoint(x: 0.50 * w, y: 0.12 * h),
                CGPoint(x: 0.80 * w, y: 0.42 * h),
                CGPoint(x: 0.55 * w, y: 0.78 * h),
                CGPoint(x: 0.22 * w, y: 0.66 * h)
            ]
            ZStack {
                Path { p in
                    p.move(to: pts[0])
                    p.addLine(to: pts[1])
                    p.addLine(to: pts[2])
                    p.addLine(to: pts[3])
                    p.addLine(to: pts[4])
                }
                .stroke(color.opacity(0.7), style: StrokeStyle(lineWidth: size * 0.05, lineCap: .round, lineJoin: .round))
                ForEach(0..<pts.count, id: \.self) { i in
                    Circle()
                        .fill(color)
                        .frame(width: size * 0.13, height: size * 0.13)
                        .position(pts[i])
                }
            }
        }
        .frame(width: size, height: size)
    }
}

// Stacked layers = atlas / collection.
struct WeaverAtlasIcon: View {
    var size: CGFloat = 24
    var color: Color = WeaverTheme.textPrimary

    var body: some View {
        WeaverAtlasShape()
            .stroke(color, style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round, lineJoin: .round))
            .frame(width: size, height: size)
    }
}

struct WeaverAtlasShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let w = rect.width, h = rect.height
        // top diamond
        p.move(to: CGPoint(x: 0.5 * w, y: 0.12 * h))
        p.addLine(to: CGPoint(x: 0.88 * w, y: 0.34 * h))
        p.addLine(to: CGPoint(x: 0.5 * w, y: 0.56 * h))
        p.addLine(to: CGPoint(x: 0.12 * w, y: 0.34 * h))
        p.closeSubpath()
        // lower layer
        p.move(to: CGPoint(x: 0.12 * w, y: 0.56 * h))
        p.addLine(to: CGPoint(x: 0.5 * w, y: 0.78 * h))
        p.addLine(to: CGPoint(x: 0.88 * w, y: 0.56 * h))
        return p
    }
}

// Globe-ish region selector icon.
struct WeaverSkiesIcon: View {
    var size: CGFloat = 24
    var color: Color = WeaverTheme.textPrimary

    var body: some View {
        ZStack {
            Circle()
                .stroke(color, lineWidth: size * 0.07)
            Ellipse()
                .stroke(color, lineWidth: size * 0.05)
                .frame(width: size * 0.42, height: size)
            Path { p in
                p.move(to: CGPoint(x: size * 0.06, y: size * 0.5))
                p.addLine(to: CGPoint(x: size * 0.94, y: size * 0.5))
            }
            .stroke(color, lineWidth: size * 0.05)
        }
        .frame(width: size, height: size)
    }
}

// Gear-ish settings icon, drawn from shapes (no SF Symbol).
struct WeaverSettingsIcon: View {
    var size: CGFloat = 24
    var color: Color = WeaverTheme.textPrimary

    var body: some View {
        ZStack {
            WeaverGearShape()
                .fill(color)
            Circle()
                .fill(WeaverTheme.skyTop)
                .frame(width: size * 0.30, height: size * 0.30)
        }
        .frame(width: size, height: size)
    }
}

struct WeaverGearShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let c = CGPoint(x: rect.midX, y: rect.midY)
        let outer = min(rect.width, rect.height) / 2
        let inner = outer * 0.74
        let teeth = 8
        let steps = teeth * 2
        for i in 0..<steps {
            let angle = (CGFloat(i) / CGFloat(steps)) * 2 * .pi
            let radius = (i % 2 == 0) ? outer : inner
            let pt = CGPoint(x: c.x + cos(angle) * radius,
                             y: c.y + sin(angle) * radius)
            if i == 0 { p.move(to: pt) } else { p.addLine(to: pt) }
        }
        p.closeSubpath()
        return p
    }
}

// Plus icon for "new" actions.
struct WeaverPlusIcon: View {
    var size: CGFloat = 24
    var color: Color = WeaverTheme.textPrimary

    var body: some View {
        Path { p in
            p.move(to: CGPoint(x: size * 0.5, y: size * 0.15))
            p.addLine(to: CGPoint(x: size * 0.5, y: size * 0.85))
            p.move(to: CGPoint(x: size * 0.15, y: size * 0.5))
            p.addLine(to: CGPoint(x: size * 0.85, y: size * 0.5))
        }
        .stroke(color, style: StrokeStyle(lineWidth: size * 0.12, lineCap: .round))
        .frame(width: size, height: size)
    }
}

// Chevron back arrow.
struct WeaverBackIcon: View {
    var size: CGFloat = 24
    var color: Color = WeaverTheme.textPrimary

    var body: some View {
        Path { p in
            p.move(to: CGPoint(x: size * 0.62, y: size * 0.20))
            p.addLine(to: CGPoint(x: size * 0.32, y: size * 0.50))
            p.addLine(to: CGPoint(x: size * 0.62, y: size * 0.80))
        }
        .stroke(color, style: StrokeStyle(lineWidth: size * 0.12, lineCap: .round, lineJoin: .round))
        .frame(width: size, height: size)
    }
}

// Trash / delete icon.
struct WeaverTrashIcon: View {
    var size: CGFloat = 24
    var color: Color = WeaverTheme.textPrimary

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                // lid
                Path { p in
                    p.move(to: CGPoint(x: 0.18 * w, y: 0.26 * h))
                    p.addLine(to: CGPoint(x: 0.82 * w, y: 0.26 * h))
                }
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.09, lineCap: .round))
                Path { p in
                    p.move(to: CGPoint(x: 0.40 * w, y: 0.26 * h))
                    p.addLine(to: CGPoint(x: 0.40 * w, y: 0.16 * h))
                    p.addLine(to: CGPoint(x: 0.60 * w, y: 0.16 * h))
                    p.addLine(to: CGPoint(x: 0.60 * w, y: 0.26 * h))
                }
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round, lineJoin: .round))
                // can body
                Path { p in
                    p.move(to: CGPoint(x: 0.26 * w, y: 0.30 * h))
                    p.addLine(to: CGPoint(x: 0.30 * w, y: 0.82 * h))
                    p.addLine(to: CGPoint(x: 0.70 * w, y: 0.82 * h))
                    p.addLine(to: CGPoint(x: 0.74 * w, y: 0.30 * h))
                }
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: size, height: size)
    }
}

// Pencil / edit icon.
struct WeaverEditIcon: View {
    var size: CGFloat = 24
    var color: Color = WeaverTheme.textPrimary

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                Path { p in
                    p.move(to: CGPoint(x: 0.66 * w, y: 0.18 * h))
                    p.addLine(to: CGPoint(x: 0.82 * w, y: 0.34 * h))
                    p.addLine(to: CGPoint(x: 0.34 * w, y: 0.82 * h))
                    p.addLine(to: CGPoint(x: 0.18 * w, y: 0.82 * h))
                    p.addLine(to: CGPoint(x: 0.18 * w, y: 0.66 * h))
                    p.closeSubpath()
                }
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: size, height: size)
    }
}

// Trace tab icon: a target dot with a dashed path being drawn toward it.
struct WeaverTraceIcon: View {
    var size: CGFloat = 24
    var color: Color = WeaverTheme.textPrimary

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                // dashed guide path
                Path { p in
                    p.move(to: CGPoint(x: 0.16 * w, y: 0.80 * h))
                    p.addLine(to: CGPoint(x: 0.44 * w, y: 0.40 * h))
                    p.addLine(to: CGPoint(x: 0.74 * w, y: 0.60 * h))
                }
                .stroke(color.opacity(0.6),
                        style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round, lineJoin: .round, dash: [size * 0.10, size * 0.09]))
                // node dots
                Circle().fill(color).frame(width: size * 0.13, height: size * 0.13)
                    .position(x: 0.16 * w, y: 0.80 * h)
                Circle().fill(color).frame(width: size * 0.13, height: size * 0.13)
                    .position(x: 0.44 * w, y: 0.40 * h)
                // target ring
                Circle().stroke(color, lineWidth: size * 0.07)
                    .frame(width: size * 0.30, height: size * 0.30)
                    .position(x: 0.74 * w, y: 0.60 * h)
                Circle().fill(color).frame(width: size * 0.10, height: size * 0.10)
                    .position(x: 0.74 * w, y: 0.60 * h)
            }
        }
        .frame(width: size, height: size)
    }
}

// Hint icon: a small lantern / glow burst.
struct WeaverHintIcon: View {
    var size: CGFloat = 24
    var color: Color = WeaverTheme.textPrimary

    var body: some View {
        GeometryReader { geo in
            let c = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let r = min(geo.size.width, geo.size.height) / 2
            ZStack {
                // rays
                Path { p in
                    let rays = 8
                    for i in 0..<rays {
                        let a = (CGFloat(i) / CGFloat(rays)) * 2 * .pi
                        p.move(to: CGPoint(x: c.x + cos(a) * r * 0.62, y: c.y + sin(a) * r * 0.62))
                        p.addLine(to: CGPoint(x: c.x + cos(a) * r * 0.95, y: c.y + sin(a) * r * 0.95))
                    }
                }
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round))
                Circle().fill(color).frame(width: r * 0.7, height: r * 0.7)
            }
        }
        .frame(width: size, height: size)
    }
}

// Checkmark for discovered / earned states.
struct WeaverCheckIcon: View {
    var size: CGFloat = 24
    var color: Color = WeaverTheme.textPrimary

    var body: some View {
        Path { p in
            p.move(to: CGPoint(x: size * 0.20, y: size * 0.54))
            p.addLine(to: CGPoint(x: size * 0.42, y: size * 0.76))
            p.addLine(to: CGPoint(x: size * 0.82, y: size * 0.26))
        }
        .stroke(color, style: StrokeStyle(lineWidth: size * 0.13, lineCap: .round, lineJoin: .round))
        .frame(width: size, height: size)
    }
}

// Trophy icon for achievements.
struct WeaverTrophyIcon: View {
    var size: CGFloat = 24
    var color: Color = WeaverTheme.textPrimary

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                // cup
                Path { p in
                    p.move(to: CGPoint(x: 0.28 * w, y: 0.18 * h))
                    p.addLine(to: CGPoint(x: 0.72 * w, y: 0.18 * h))
                    p.addLine(to: CGPoint(x: 0.66 * w, y: 0.52 * h))
                    p.addLine(to: CGPoint(x: 0.34 * w, y: 0.52 * h))
                    p.closeSubpath()
                }
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round, lineJoin: .round))
                // handles
                Path { p in
                    p.addArc(center: CGPoint(x: 0.24 * w, y: 0.28 * h), radius: 0.12 * w,
                             startAngle: .degrees(300), endAngle: .degrees(120), clockwise: false)
                }
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round))
                Path { p in
                    p.addArc(center: CGPoint(x: 0.76 * w, y: 0.28 * h), radius: 0.12 * w,
                             startAngle: .degrees(240), endAngle: .degrees(60), clockwise: true)
                }
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.07, lineCap: .round))
                // stem + base
                Path { p in
                    p.move(to: CGPoint(x: 0.5 * w, y: 0.52 * h))
                    p.addLine(to: CGPoint(x: 0.5 * w, y: 0.72 * h))
                    p.move(to: CGPoint(x: 0.34 * w, y: 0.84 * h))
                    p.addLine(to: CGPoint(x: 0.66 * w, y: 0.84 * h))
                }
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round, lineJoin: .round))
            }
        }
        .frame(width: size, height: size)
    }
}

// Lock icon for locked skies.
struct WeaverLockIcon: View {
    var size: CGFloat = 24
    var color: Color = WeaverTheme.textPrimary

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width, h = geo.size.height
            ZStack {
                RoundedRectangle(cornerRadius: size * 0.10)
                    .stroke(color, lineWidth: size * 0.08)
                    .frame(width: 0.62 * w, height: 0.46 * h)
                    .position(x: 0.5 * w, y: 0.66 * h)
                Path { p in
                    p.addArc(center: CGPoint(x: 0.5 * w, y: 0.42 * h),
                             radius: 0.18 * w,
                             startAngle: .degrees(180), endAngle: .degrees(0),
                             clockwise: false)
                }
                .stroke(color, style: StrokeStyle(lineWidth: size * 0.08, lineCap: .round))
            }
        }
        .frame(width: size, height: size)
    }
}
