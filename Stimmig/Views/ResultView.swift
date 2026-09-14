import SwiftUI

struct ResultView: View {
    let core: CoreEmotion
    let sub: SubEmotion
    let word: String
    @Binding var note: String
    let onSave: () -> Void
    let onAgain: () -> Void

    @State private var saved = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Text("DEIN GEFÜHL")
                    .font(.system(size: 13, weight: .semibold))
                    .tracking(1.2)
                    .foregroundStyle(AppColor.muted)
                Text(word)
                    .font(.display(48))
                    .tracking(-1.5)
                    .padding(.top, 4)
                HStack(spacing: 4) {
                    Text(core.name).fontWeight(.semibold).foregroundStyle(AppColor.ink)
                    Text("›").foregroundStyle(AppColor.muted)
                    Text(sub.name).foregroundStyle(AppColor.muted)
                }
                .font(.system(size: 15))
                .padding(.bottom, 20)

                VStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 3)
                        .fill(core.color)
                        .frame(width: 34, height: 6)
                    Text(core.reflect)
                        .font(.system(size: 15.5))
                        .foregroundStyle(AppColor.bodyText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
                .padding(22)
                .frame(maxWidth: 330)
                .background(AppColor.card)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(AppColor.line))
                .shadow(color: .black.opacity(0.12), radius: 25, y: 14)

                TextField("Notiz (optional) – was war gerade los?", text: $note, axis: .vertical)
                    .lineLimit(2...4)
                    .font(.system(size: 14))
                    .padding(12)
                    .frame(maxWidth: 330)
                    .background(AppColor.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColor.line))
                    .padding(.top, 16)

                VStack(spacing: 8) {
                    Button(action: {
                        onSave()
                        saved = true
                    }) {
                        Text(saved ? "Gespeichert ✓" : "Im Tagebuch speichern")
                            .font(.display(17))
                            .foregroundStyle(.white)
                            .frame(minWidth: 230)
                            .padding(.vertical, 16)
                            .background(saved ? AppColor.saved : AppColor.highlight)
                            .clipShape(Capsule())
                    }
                    .disabled(saved)

                    Button(action: onAgain) {
                        Text("Nochmal fühlen")
                            .font(.display(17))
                            .foregroundStyle(AppColor.highlight)
                            .padding(.vertical, 14)
                            .padding(.horizontal, 22)
                    }
                }
                .padding(.top, 16)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .onAppear { saved = false }
    }
}
