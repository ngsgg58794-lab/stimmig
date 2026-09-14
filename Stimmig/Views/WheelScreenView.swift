import SwiftUI

struct WheelScreenView: View {
    let step: Step
    let core: CoreEmotion?
    let sub: SubEmotion?
    let onPickCore: (Int) -> Void
    let onPickSub: (Int) -> Void
    let onPickWord: (Int) -> Void

    private var askTitle: String {
        switch step {
        case .core: return "Wie fühlst du dich?"
        case .secondary: return "Etwas genauer?"
        case .tertiary: return "Und ganz genau?"
        default: return ""
        }
    }

    private var askSubtitle: String {
        switch step {
        case .core: return "Wähle, was dem Kern am nächsten kommt."
        case .secondary: return "Welche Richtung trifft es besser?"
        case .tertiary: return "Das Wort, das wirklich passt."
        default: return ""
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            Spacer(minLength: 0)

            ZStack {
                EmotionWheelCanvas(
                    step: step, core: core, sub: sub,
                    onPickCore: onPickCore, onPickSub: onPickSub, onPickWord: onPickWord
                )
                Circle()
                    .fill(AppColor.highlight.opacity(0.15))
                    .frame(width: 26, height: 26)
                Circle()
                    .fill(AppColor.highlight)
                    .frame(width: 14, height: 14)
            }
            .frame(maxWidth: 340, maxHeight: 340)
            .aspectRatio(1, contentMode: .fit)
            .id(step)
            .transition(.opacity.combined(with: .move(edge: .bottom)))

            VStack(spacing: 4) {
                breadcrumb
                Text(askTitle)
                    .font(.display(26))
                    .tracking(-0.6)
                Text(askSubtitle)
                    .font(.system(size: 14))
                    .foregroundStyle(AppColor.muted)
            }
            .multilineTextAlignment(.center)
            .animation(.easeOut(duration: 0.25), value: step)

            Spacer(minLength: 0)
        }
        .animation(.easeOut(duration: 0.3), value: step)
    }

    @ViewBuilder
    private var breadcrumb: some View {
        HStack(spacing: 4) {
            if let core {
                Text(core.name).fontWeight(.semibold)
            }
            if let sub {
                Text("›").foregroundStyle(AppColor.highlight).fontWeight(.bold)
                Text(sub.name).fontWeight(.semibold)
            }
        }
        .font(.system(size: 13))
        .foregroundStyle(AppColor.muted)
        .frame(minHeight: 18)
    }
}
