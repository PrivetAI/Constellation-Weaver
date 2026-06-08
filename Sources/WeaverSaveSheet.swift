import SwiftUI

struct WeaverSaveSheet: View {
    let sky: WeaverSky
    let stars: [WeaverStar]
    let edges: [WeaverEdge]
    let onSaved: () -> Void

    @EnvironmentObject var store: WeaverStore
    @Environment(\.presentationMode) private var presentationMode

    @State private var name: String = ""
    @State private var note: String = ""

    // Only the stars actually used, snapshotted into the saved figure.
    private var usedStars: [WeaverStar] {
        let ids = Set(edges.flatMap { [$0.a, $0.b] })
        return stars.filter { ids.contains($0.id) }
    }

    var body: some View {
        ZStack {
            WeaverTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                handle

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        Text("Name your constellation")
                            .font(.system(size: 22, weight: .semibold, design: .serif))
                            .foregroundColor(WeaverTheme.textPrimary)

                        // Preview
                        ZStack {
                            RoundedRectangle(cornerRadius: 16).fill(WeaverTheme.skyTop)
                            WeaverFigureView(stars: usedStars, edges: edges,
                                             hueIndex: sky.hueIndex,
                                             showAllStars: false)
                                .padding(18)
                        }
                        .frame(height: 200)
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))

                        fieldLabel("Name")
                        WeaverTextField(text: $name, placeholder: "e.g. The Wanderer")

                        fieldLabel("Note (optional)")
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

                            Button { save() } label: {
                                Text("Save to Atlas")
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
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !edges.isEmpty
    }

    private var handle: some View {
        Capsule()
            .fill(WeaverTheme.stroke)
            .frame(width: 40, height: 5)
            .padding(.top, 10)
    }

    private func fieldLabel(_ s: String) -> some View {
        Text(s)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(WeaverTheme.textFaint)
    }

    private func save() {
        let trimmed = name.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        let c = WeaverConstellation(
            name: trimmed,
            note: note.trimmingCharacters(in: .whitespacesAndNewlines),
            skyId: sky.id,
            skyName: sky.name,
            hueIndex: sky.hueIndex,
            stars: usedStars,
            edges: edges)
        store.add(c)
        onSaved()
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - Custom text inputs (custom-styled, theme-fixed)

struct WeaverTextField: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        ZStack(alignment: .leading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(WeaverTheme.textFaint)
                    .font(.system(size: 16))
                    .padding(.horizontal, 14)
            }
            TextField("", text: $text)
                .foregroundColor(WeaverTheme.textPrimary)
                .font(.system(size: 16))
                .padding(.horizontal, 14)
                .accentColor(WeaverTheme.line)
        }
        .frame(height: 50)
        .background(WeaverTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))
    }
}

struct WeaverTextEditor: View {
    @Binding var text: String
    let placeholder: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(WeaverTheme.textFaint)
                    .font(.system(size: 15))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 14)
            }
            TextEditor(text: $text)
                .foregroundColor(WeaverTheme.textPrimary)
                .font(.system(size: 15))
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .accentColor(WeaverTheme.line)
                .scrollContentBackgroundHiddenCompat()
        }
        .frame(height: 100)
        .background(WeaverTheme.panel)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(RoundedRectangle(cornerRadius: 12).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))
    }
}

// TextEditor background on iOS 15 isn't controllable via scrollContentBackground
// (that's iOS 16+). Provide a no-op modifier so we stay 15.6-compatible while
// still having a panel-colored container behind it (TextEditor is transparent
// enough over our solid background here).
extension View {
    @ViewBuilder
    func scrollContentBackgroundHiddenCompat() -> some View {
        self.onAppear {
            UITextView.appearance().backgroundColor = .clear
        }
    }
}
