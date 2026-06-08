import SwiftUI

struct WeaverEditSheet: View {
    let constellation: WeaverConstellation
    @EnvironmentObject var store: WeaverStore
    @Environment(\.presentationMode) private var presentationMode

    @State private var name: String
    @State private var note: String

    init(constellation: WeaverConstellation) {
        self.constellation = constellation
        _name = State(initialValue: constellation.name)
        _note = State(initialValue: constellation.note)
    }

    var body: some View {
        ZStack {
            WeaverTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                Capsule().fill(WeaverTheme.stroke).frame(width: 40, height: 5).padding(.top, 10)

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Edit constellation")
                            .font(.system(size: 22, weight: .semibold, design: .serif))
                            .foregroundColor(WeaverTheme.textPrimary)

                        ZStack {
                            RoundedRectangle(cornerRadius: 16).fill(WeaverTheme.skyTop)
                            WeaverFigureView(stars: constellation.stars,
                                             edges: constellation.edges,
                                             hueIndex: constellation.hueIndex,
                                             showAllStars: false)
                                .padding(18)
                        }
                        .frame(height: 180)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))

                        Text("Name")
                            .font(.system(size: 13, weight: .semibold)).foregroundColor(WeaverTheme.textFaint)
                        WeaverTextField(text: $name, placeholder: "Name")

                        Text("Note")
                            .font(.system(size: 13, weight: .semibold)).foregroundColor(WeaverTheme.textFaint)
                        WeaverTextEditor(text: $note, placeholder: "A memory, a wish, a story...")

                        HStack(spacing: 12) {
                            Button { presentationMode.wrappedValue.dismiss() } label: {
                                Text("Cancel")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(WeaverTheme.textSecondary)
                                    .frame(maxWidth: .infinity).frame(height: 50)
                                    .background(WeaverTheme.panelRaised)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .buttonStyle(.plain)

                            Button { saveEdits() } label: {
                                Text("Save")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(canSave ? WeaverTheme.skyTop : WeaverTheme.textFaint)
                                    .frame(maxWidth: .infinity).frame(height: 50)
                                    .background(canSave ? WeaverTheme.line : WeaverTheme.panel)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                            .disabled(!canSave)
                            .buttonStyle(.plain)
                        }
                        .padding(.top, 6)
                    }
                    .padding(20)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var canSave: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func saveEdits() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        store.rename(constellation, to: trimmed,
                     note: note.trimmingCharacters(in: .whitespacesAndNewlines))
        presentationMode.wrappedValue.dismiss()
    }
}
