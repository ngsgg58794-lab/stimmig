import SwiftUI

struct StartView: View {
    let onStart: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            BrandMark(size: 96)
                .padding(.bottom, 20)
            Text("stimmig")
                .font(.display(46))
                .tracking(-1.5)
            Text("Finde heraus, wie du dich fühlst – von innen nach außen, Schritt für Schritt.")
                .font(.system(size: 16))
                .foregroundStyle(AppColor.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
                .frame(maxWidth: 260)
                .padding(.top, 10)
                .padding(.bottom, 34)
            Button(action: onStart) {
                Text("Los geht's")
                    .font(.display(17))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 38)
                    .padding(.vertical, 16)
                    .background(AppColor.highlight)
                    .clipShape(Capsule())
                    .shadow(color: AppColor.highlight.opacity(0.4), radius: 20, y: 12)
            }
            Text("Tippe dich vom Kern deines Gefühls nach außen, bis du das Wort findest, das wirklich passt.")
                .font(.system(size: 12.5))
                .foregroundStyle(AppColor.muted)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .frame(maxWidth: 280)
                .padding(.top, 18)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}
