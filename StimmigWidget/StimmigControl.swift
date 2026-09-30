import AppIntents
import SwiftUI
import WidgetKit

/// Control Center / Lock Screen button that opens the wheel (iOS 18+).
@available(iOS 18.0, *)
struct StimmigControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(kind: "com.pinksharkdesign.stimmig.open-wheel") {
            ControlWidgetButton(action: OpenWheelIntent()) {
                Label("Gefühl finden", systemImage: "circle.circle")
            }
        }
        .displayName("Gefühl finden")
        .description("Öffnet stimmig direkt im Gefühlsrad.")
    }
}
