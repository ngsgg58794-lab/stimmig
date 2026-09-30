import SwiftUI

struct WheelBand {
    let mid: CGFloat
    let thickness: CGFloat
}

enum WheelGeometry {
    static let viewBoxSize: CGFloat = 380
    static let bands: [WheelBand] = [
        WheelBand(mid: 70, thickness: 52),
        WheelBand(mid: 122, thickness: 48),
        WheelBand(mid: 166, thickness: 40),
    ]
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
            let bands = WheelGeometry.bands

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
        let innerR = (band.mid - band.thickness / 2) * scale
        let outerR = (band.mid + band.thickness / 2) * scale
        let grownR = outerR + 12 * scale

        ForEach(0..<n, id: \.self) { i in
            let a0 = Double(i) * span
            let a1 = Double(i + 1) * span
            let midAngle = (a0 + a1) / 2
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
                        .font(.display(labels[i].count > 11 ? 10.5 : 12.5, weight: .bold))
                        .foregroundStyle(AppColor.onEmotion)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
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
}
