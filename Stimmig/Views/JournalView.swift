import SwiftUI

struct JournalView: View {
    @ObservedObject var store: JournalStore
    let onNew: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Text("Tagebuch")
                .font(.display(30))
                .tracking(-0.8)
                .padding(.top, 6)
            Text(countLabel)
                .font(.system(size: 13))
                .foregroundStyle(AppColor.muted)
                .frame(minHeight: 16)
                .padding(.bottom, 12)

            if store.entries.isEmpty {
                Spacer()
                Text("Noch keine Einträge.\nFinde ein Gefühl und speichere es hier.")
                    .font(.system(size: 15))
                    .foregroundStyle(AppColor.muted)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                Spacer()
            } else {
                ScrollView {
                    VStack(spacing: 10) {
                        ForEach(store.entries) { entry in
                            JournalEntryRow(entry: entry) {
                                store.delete(id: entry.id)
                            }
                        }
                    }
                    .padding(.bottom, 8)
                }
            }

            Button(action: onNew) {
                Text("Neues Gefühl finden")
                    .font(.display(17))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 30)
                    .padding(.vertical, 16)
                    .background(AppColor.highlight)
                    .clipShape(Capsule())
            }
            .padding(.top, 10)
            .padding(.bottom, 4)
        }
    }

    private var countLabel: String {
        let n = store.entries.count
        guard n > 0 else { return "" }
        return "\(n) \(n == 1 ? "Eintrag" : "Einträge")"
    }
}

private struct JournalEntryRow: View {
    let entry: JournalEntry
    let onDelete: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color(hex: entry.colorHex))
                .frame(width: 10)
                .fixedSize(horizontal: false, vertical: false)

            VStack(alignment: .leading, spacing: 4) {
                Text(entry.word)
                    .font(.display(18))
                    .tracking(-0.3)
                Text("\(entry.coreName) › \(entry.subName) · \(formattedDate)")
                    .font(.system(size: 12.5))
                    .foregroundStyle(AppColor.muted)
                if let question = entry.question, !entry.note.isEmpty {
                    Text(question)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundStyle(AppColor.muted)
                        .padding(.top, 4)
                }
                if !entry.note.isEmpty {
                    Text(entry.note)
                        .font(.system(size: 13.5))
                        .foregroundStyle(AppColor.bodyText)
                        .padding(.top, 4)
                }
            }
            Spacer(minLength: 0)
            Button(action: onDelete) {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(AppColor.muted)
            }
        }
        .padding(13)
        .background(AppColor.card)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppColor.line))
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "de_DE")
        formatter.dateFormat = "dd. MMM yyyy · HH:mm"
        return formatter.string(from: entry.timestamp)
    }
}
