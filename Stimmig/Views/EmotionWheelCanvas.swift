import SwiftUI

struct WheelBand {
    let mid: CGFloat
    let thickness: CGFloat

    init(inner: CGFloat, outer: CGFloat) {
        mid = (inner + outer) / 2
        thickness = outer - inner
    }
}

enum WheelGeometry {
    static let viewBoxSize: CGFloat = 380

    /// Ring layout per step (core, sub, word). The active ring gets most of the radius
    /// so its labels have room; finished rings shrink toward the centre.
    static func bands(for step: Step) -> [WheelBand] {
        switch step {
        case .secondary:
            return [WheelBand(inner: 34, outer: 78), WheelBand(inner: 78, outer: 176), WheelBand(inner: 176, outer: 188)]
        case .tertiary:
            return [WheelBand(inner: 34, outer: 62), WheelBand(inner: 62, outer: 92), WheelBand(inner: 92, outer: 188)]
        default:
            return [WheelBand(inner: 34, outer: 156), WheelBand(inner: 156, outer: 172), WheelBand(inner: 172, outer: 188)]
        }
    }
}

/// Draws the three concentric rings of the feelings wheel: completed rings behind as
/// solid/ghost circles, and the currently active ring as tappable colored segments —
/// mirrors the `render()` function from the web app.
struct EmotionWheelCanvas: View {
    let step: Step
    let core: CoreEmotion?
    let sub: SubEmotion?
    let onPickCore: (Int) -> Void
    let onPickSub: (Int) -> Void
    let onPickWord: (Int) -> Void

    /// Segment that was just tapped; it grows outward before the wheel moves on.
    @State private var picked: Int?

    var body: some View {
        GeometryReader { geo in
            let scale = geo.size.width / WheelGeometry.viewBoxSize
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let bands = WheelGeometry.bands(for: step)

            ZStack {
                if step == .core {
                    ringView(band: bands[1], scale: scale, center: center, color: AppColor.ghostRing)
                    ringView(band: bands[2], scale: scale, center: center, color: AppColor.ghostRing)
                    segments(
                        band: bands[0], scale: scale, center: center,
                        labels: EmotionWheelData.core.map(\.name),
                        colorFor: { EmotionWheelData.core[$0].color },
                        onPick: onPickCore)
                }
                if step == .secondary, let core {
                    ringView(band: bands[0], scale: scale, center: center, color: core.color)
                    ringView(band: bands[2], scale: scale, center: center, color: AppColor.ghostRing)
                    segments(
                        band: bands[1], scale: scale, center: center,
                        labels: core.subs.map(\.name),
                        colorFor: { i in i % 2 == 1 ? core.color.mixedWithWhite(0.34) : core.color.mixedWithWhite(0.18) },
                        onPick: onPickSub)
                }
                if step == .tertiary, let core, let sub {
                    ringView(band: bands[0], scale: scale, center: center, color: core.color)
                    ringView(band: bands[1], scale: scale, center: center, color: core.color.mixedWithWhite(0.26))
                    segments(
                        band: bands[2], scale: scale, center: center,
                        labels: sub.words,
                        colorFor: { i in i % 2 == 1 ? core.color.mixedWithWhite(0.5) : core.color.mixedWithWhite(0.38) },
                        onPick: onPickWord)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }

    private func ringView(band: WheelBand, scale: CGFloat, center: CGPoint, color: Color) -> some View {
        Circle()
            .stroke(color, lineWidth: band.thickness * scale)
            .frame(width: band.mid * 2 * scale, height: band.mid * 2 * scale)
            .position(center)
    }

    @ViewBuilder
    private func segments(
        band: WheelBand, scale: CGFloat, center: CGPoint, labels: [String],
        colorFor: @escaping (Int) -> Color, onPick: @escaping (Int) -> Void
    ) -> some View {
        let n = labels.count
        let span = 360.0 / Double(n)
        // With two segments, put them top and bottom so the horizontal labels run along the ring.
        let offset = n == 2 ? -90.0 : 0
        let innerR = (band.mid - band.thickness / 2) * scale
        let outerR = (band.mid + band.thickness / 2) * scale
        let grownR = outerR + 8 * scale
        let chord = 2 * band.mid * scale * CGFloat(sin(min(span, 180) / 2 * .pi / 180))

        ForEach(0..<n, id: \.self) { i in
            let a0 = offset + Double(i) * span
            let a1 = offset + Double(i + 1) * span
            let midAngle = (a0 + a1) / 2
            let labelWidth = Self.labelWidth(midAngle: midAngle, chord: chord, thickness: band.thickness * scale)
            let isPicked = picked == i
            let wedge = WedgeShape(
                innerRadius: innerR, outerRadius: isPicked ? grownR : outerR,
                startAngle: a0 + 1, endAngle: a1 - 1, center: center
            )

            wedge
                .fill(colorFor(i))
                .overlay(wedge.stroke(AppColor.background, lineWidth: 2))
                .opacity(picked == nil || isPicked ? 1 : 0.45)
                .contentShape(wedge)
                .onTapGesture { pick(i, then: onPick) }
                .overlay(
                    Text(labels[i])
                        .font(.display(16, weight: .bold))
                        .foregroundStyle(AppColor.onEmotion)
                        .lineLimit(1)
                        .minimumScaleFactor(0.55)
                        .frame(width: labelWidth)
                        .position(polarPoint(band.mid * scale, midAngle, center: center))
                        .allowsHitTesting(false)
                )
        }
    }

    private func pick(_ i: Int, then onPick: @escaping (Int) -> Void) {
        guard picked == nil else { return }
        Haptics.tap()
        withAnimation(.spring(response: 0.28, dampingFraction: 0.6)) { picked = i }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.22) { onPick(i) }
    }

    /// Horizontal room for a label centred in a ring segment: the chord where the segment
    /// runs sideways (top/bottom), the ring thickness where it runs up/down (left/right).
    private static func labelWidth(midAngle: Double, chord: CGFloat, thickness: CGFloat) -> CGFloat {
        let a = midAngle * .pi / 180
        let width = thickness * CGFloat(abs(sin(a))) + chord * CGFloat(abs(cos(a)))
        return max(40, min(width, chord) * 0.86)
    }
}
