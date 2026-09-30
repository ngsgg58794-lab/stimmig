import SwiftUI

/// One-minute guided exercise with animation, timer and gentle haptics.
struct ExerciseView: View {
    let exercise: Exercise
    @Environment(\.dismiss) private var dismiss

    @State private var started = false
    @State private var finished = false
    @State private var endDate = Date()
    @State private var scale: CGFloat = 0.35
    @State private var phaseLabel = ""
    @State private var stepIndex = 0

    private var color: Color { Color(hex: exercise.colorHex) }

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.system(size: 15, weight: .semibold))
                        .frame(width: 36, height: 36)
                        .background(AppColor.highlightSoft)
                        .foregroundStyle(AppColor.highlight)
                        .clipShape(Circle())
                }
                .accessibilityLabel("Schließen")
            }
            .padding(.top, 8)

            Text(exercise.title)
                .font(.display(30))
                .tracking(-0.8)
                .padding(.top, 4)
            Text(exercise.intro)
                .font(.system(size: 15))
                .foregroundStyle(AppColor.muted)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
                .padding(.top, 6)

            Spacer()
            visual
            Spacer()

            if started && !finished {
                TimelineView(.periodic(from: .now, by: 1)) { context in
                    Text(remaining(at: context.date))
                        .font(.system(size: 15, weight: .semibold).monospacedDigit())
                        .foregroundStyle(AppColor.muted)
                }
                .padding(.bottom, 20)
            }

            Button(action: primaryAction) {
                Text(finished ? "Fertig" : started ? "Beenden" : "Starten · 1 Minute")
                    .font(.display(17))
                    .foregroundStyle(.white)
                    .frame(minWidth: 230)
                    .padding(.vertical, 16)
                    .background(AppColor.highlight)
                    .clipShape(Capsule())
            }
            .padding(.bottom, 16)
        }
        .padding(.horizontal, 22)
        .background(AppColor.background.ignoresSafeArea())
        .task(id: started) {
            guard started else { return }
            await run()
        }
    }

    // MARK: - Visual

    @ViewBuilder
    private var visual: some View {
        ZStack {
            Circle()
                .fill(color.opacity(0.18))
                .frame(width: 260, height: 260)
            Circle()
                .fill(color)
                .frame(width: 260, height: 260)
                .scaleEffect(scale)
                .shadow(color: color.opacity(0.5), radius: 30)

            Group {
                if finished {
                    VStack(spacing: 6) {
                        Image(systemName: "checkmark")
                            .font(.system(size: 30, weight: .bold))
                        Text("Gut gemacht.")
                            .font(.display(20))
                    }
                } else if case .guided(let steps, _) = exercise.kind, started {
                    Text(steps[min(stepIndex, steps.count - 1)])
                        .font(.display(19))
                        .multilineTextAlignment(.center)
                        .frame(width: 210)
                        .id(stepIndex)
                        .transition(.opacity)
                } else {
                    Text(started ? phaseLabel : "Bereit?")
                        .font(.display(22))
                        .id(phaseLabel)
                        .transition(.opacity)
                }
            }
            .foregroundStyle(AppColor.onEmotion)
            .animation(.easeInOut(duration: 0.4), value: stepIndex)
            .animation(.easeInOut(duration: 0.4), value: phaseLabel)
        }
        .frame(height: 280)
    }

    // MARK: - Flow

    private func primaryAction() {
        if finished || started {
            dismiss()
        } else {
            endDate = Date().addingTimeInterval(Exercise.duration)
            started = true
        }
    }

    private func remaining(at date: Date) -> String {
        let seconds = max(0, Int(endDate.timeIntervalSince(date).rounded(.up)))
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    private func run() async {
        switch exercise.kind {
        case .breathing(let phases):
            while Date() < endDate {
                for phase in phases {
                    guard !Task.isCancelled else { return }
                    phaseLabel = phase.label
                    Haptics.soft()
                    withAnimation(.easeInOut(duration: phase.seconds)) { scale = phase.scale }
                    try? await Task.sleep(nanoseconds: UInt64(phase.seconds * 1_000_000_000))
                }
            }
        case .guided(let steps, let seconds):
            withAnimation(.easeInOut(duration: 1.2)) { scale = 1 }
            for index in steps.indices {
                guard !Task.isCancelled else { return }
                stepIndex = index
                Haptics.soft()
                // Slow "breathing" of the circle while each prompt is shown.
                withAnimation(.easeInOut(duration: seconds)) {
                    scale = index.isMultiple(of: 2) ? 0.8 : 1
                }
                try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
            }
        }
        guard !Task.isCancelled else { return }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            scale = 1
            finished = true
        }
        Haptics.success()
    }
}
