import SwiftUI

/// Stylised approximation of the web app's swirl logo (two open rings + core dot).
struct BrandMark: View {
    var size: CGFloat = 28

    var body: some View {
        ZStack {
            Circle()
                .trim(from: 0, to: 0.78)
                .stroke(Color(hex: "#FFB0CE"), style: StrokeStyle(lineWidth: size * 0.14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(size * 0.02)
            Circle()
                .trim(from: 0, to: 0.68)
                .stroke(AppColor.highlight, style: StrokeStyle(lineWidth: size * 0.14, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(size * 0.22)
            Circle()
                .fill(AppColor.highlight)
                .frame(width: size * 0.19, height: size * 0.19)
        }
        .frame(width: size, height: size)
    }
}
