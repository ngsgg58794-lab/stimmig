import SwiftUI

/// A point on a circle of radius `r` at `deg` degrees, measured clockwise from the top —
/// matches the `polar()` helper from the original web app.
func polarPoint(_ r: CGFloat, _ deg: Double, center: CGPoint) -> CGPoint {
    let a = (deg - 90) * .pi / 180
    return CGPoint(x: center.x + r * CGFloat(cos(a)), y: center.y + r * CGFloat(sin(a)))
}

/// A tappable annulus segment (ring wedge), built from absolute coordinates in the
/// parent's coordinate space rather than the shape's own `rect`, so it composes
/// cleanly with a `GeometryReader`-driven wheel layout.
struct WedgeShape: Shape {
    var innerRadius: CGFloat
    var outerRadius: CGFloat
    var startAngle: Double
    var endAngle: Double
    var center: CGPoint

    /// Lets the outer edge animate, so a picked segment can grow outward smoothly.
    var animatableData: CGFloat {
        get { outerRadius }
        set { outerRadius = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let steps = max(2, Int(abs(endAngle - startAngle) / 3))

        var outerPoints: [CGPoint] = []
        for i in 0...steps {
            let t = startAngle + (endAngle - startAngle) * Double(i) / Double(steps)
            outerPoints.append(polarPoint(outerRadius, t, center: center))
        }
        var innerPoints: [CGPoint] = []
        for i in 0...steps {
            let t = endAngle + (startAngle - endAngle) * Double(i) / Double(steps)
            innerPoints.append(polarPoint(innerRadius, t, center: center))
        }

        guard let first = outerPoints.first else { return path }
        path.move(to: first)
        for p in outerPoints.dropFirst() { path.addLine(to: p) }
        for p in innerPoints { path.addLine(to: p) }
        path.closeSubpath()
        return path
    }
}
