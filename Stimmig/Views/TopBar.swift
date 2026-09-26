import SwiftUI

struct TopBar: View {
    let step: Step
    let onBack: () -> Void
    let onOpen: (Step) -> Void

    private var isWheelStep: Bool {
        step == .core || step == .secondary || step == .tertiary
    }

    private var litCount: Int {
        switch step {
        case .core: return 1
        case .secondary: return 2
        case .tertiary: return 3
        default: return 0
        }
    }

    var body: some View {
        HStack {
            HStack(spacing: 9) {
                BrandMark(size: 26)
                Text("stimmig")
                    .font(.display(18))
                    .tracking(-0.3)
            }
            .opacity(step == .start ? 0 : 1)

            Spacer()

            HStack(spacing: 8) {
                if isWheelStep || Step.overlays.contains(step) {
                    Button(action: onBack) {
                        Text("‹ zurück")
                            .font(.system(size: 14, weight: .semibold))
                    }
                    .foregroundStyle(AppColor.highlight)
                }
                if isWheelStep {
                    HStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { i in
                            Circle()
                                .fill(i < litCount ? AppColor.highlight : AppColor.line)
                                .frame(width: 7, height: 7)
                                .scaleEffect(i < litCount ? 1.25 : 1.0)
                        }
                    }
                }
                if step == .start || step == .result {
                    iconButton("chart.bar.xaxis", label: "Einblicke") { onOpen(.insights) }
                    iconButton("gearshape", label: "Einstellungen") { onOpen(.settings) }
                    Button(action: { onOpen(.journal) }) {
                        HStack(spacing: 6) {
                            Image(systemName: "book.closed")
                                .font(.system(size: 12, weight: .semibold))
                            Text("Tagebuch")
                                .font(.system(size: 13, weight: .semibold))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(AppColor.highlightSoft)
                        .foregroundStyle(AppColor.highlight)
                        .clipShape(Capsule())
                    }
                }
            }
        }
        .frame(height: 40)
    }

    private func iconButton(_ systemName: String, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: 14, weight: .semibold))
                .frame(width: 34, height: 34)
                .background(AppColor.highlightSoft)
                .foregroundStyle(AppColor.highlight)
                .clipShape(Circle())
        }
        .accessibilityLabel(label)
    }
}
