import SwiftUI

struct ResultView: View {
    let core: CoreEmotion
    let sub: SubEmotion
    let word: String
    @Binding var note: String
    let onSave: (_ question: String?) -> Void
    let onAgain: () -> Void

    @State private var saved = false
    @State private var pulse = false
    @State private var questionIndex = 0
    @State private var exercise: Exercise?

    private var questions: [String] { Reflection.questions(core: core.name, sub: sub.name) }
    private var question: String { questions[questionIndex % questions.count] }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                ZStack {
                    // Short colour pulse when the result appears.
                    Circle()
                        .fill(core.color)
                        .frame(width: 160, height: 160)
                        .scaleEffect(pulse ? 2.4 : 0.3)
                        .opacity(pulse ? 0 : 0.7)
                        .allowsHitTesting(false)

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
                    }
                }
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

                questionCard
                    .padding(.top, 16)

                TextField("Deine Antwort (optional)", text: $note, axis: .vertical)
                    .lineLimit(2...4)
                    .font(.system(size: 14))
                    .padding(12)
                    .frame(maxWidth: 330)
                    .background(AppColor.card)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(RoundedRectangle(cornerRadius: 14).stroke(AppColor.line))
                    .padding(.top, 10)

                VStack(spacing: 8) {
                    Button(action: {
                        let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
                        onSave(trimmed.isEmpty ? nil : question)
                        saved = true
                        Haptics.success()
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

                    Button(action: { exercise = Exercise.forCore(core) }) {
                        Label("Übung: \(Exercise.forCore(core).title)", systemImage: "wind")
                            .font(.display(16))
                            .foregroundStyle(AppColor.highlight)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 20)
                            .background(AppColor.highlightSoft)
                            .clipShape(Capsule())
                    }

                    Button(action: onAgain) {
                        Text("Nochmal fühlen")
                            .font(.display(17))
                            .foregroundStyle(AppColor.highlight)
                            .padding(.vertical, 12)
                            .padding(.horizontal, 22)
                    }
                }
                .padding(.top, 16)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
        }
        .onAppear {
            saved = false
            pulse = false
            withAnimation(.easeOut(duration: 0.9)) { pulse = true }
            Haptics.success()
        }
        .fullScreenCover(item: $exercise) { exercise in
            ExerciseView(exercise: exercise)
        }
    }

    private var questionCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("FRAGE AN DICH")
                    .font(.system(size: 11, weight: .semibold))
                    .tracking(1)
                    .foregroundStyle(AppColor.muted)
                Spacer()
                if questions.count > 1 {
                    Button {
                        Haptics.tap()
                        withAnimation(.easeInOut(duration: 0.25)) { questionIndex += 1 }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundStyle(AppColor.highlight)
                    }
                    .accessibilityLabel("Andere Frage")
                }
            }
            Text(question)
                .font(.display(17))
                .foregroundStyle(AppColor.ink)
                .fixedSize(horizontal: false, vertical: true)
                .id(questionIndex)
                .transition(.opacity)
        }
        .padding(14)
        .frame(maxWidth: 330, alignment: .leading)
        .background(core.color.opacity(0.18))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}
