import SwiftUI

struct WeaverDetailView: View {
    let constellation: WeaverConstellation
    @EnvironmentObject var store: WeaverStore
    @Environment(\.presentationMode) private var presentationMode

    @State private var showEdit = false
    @State private var showDeleteConfirm = false

    // Pull the freshest copy from the store (name/note may have been edited).
    private var current: WeaverConstellation {
        store.constellations.first { $0.id == constellation.id } ?? constellation
    }

    var body: some View {
        ZStack {
            WeaverTheme.backgroundGradient.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 18) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18).fill(WeaverTheme.skyTop)
                        WeaverFigureView(stars: current.stars,
                                         edges: current.edges,
                                         hueIndex: current.hueIndex,
                                         showAllStars: false)
                            .padding(22)
                    }
                    .frame(height: 320)
                    .overlay(RoundedRectangle(cornerRadius: 18).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))
                    .padding(.horizontal, 16)
                    .padding(.top, 10)

                    VStack(alignment: .leading, spacing: 12) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(current.name)
                                    .font(.system(size: 26, weight: .semibold, design: .serif))
                                    .foregroundColor(WeaverTheme.textPrimary)
                                Text(current.skyName)
                                    .font(.system(size: 14))
                                    .foregroundColor(WeaverTheme.accent(current.hueIndex))
                            }
                            Spacer()
                            WeaverStarIcon(size: 22, color: WeaverTheme.accent(current.hueIndex))
                        }

                        infoRow(label: "Stars", value: "\(Set(current.edges.flatMap { [$0.a, $0.b] }).count)")
                        infoRow(label: "Lines", value: "\(current.edges.count)")
                        infoRow(label: "Woven", value: Self.dateFormatter.string(from: current.createdAt))

                        if !current.note.isEmpty {
                            Divider().background(WeaverTheme.stroke)
                            Text("Note")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(WeaverTheme.textFaint)
                            Text(current.note)
                                .font(.system(size: 15))
                                .foregroundColor(WeaverTheme.textSecondary)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    .padding(18)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(WeaverTheme.panel)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(WeaverTheme.stroke.opacity(0.6), lineWidth: 1))
                    .padding(.horizontal, 16)

                    HStack(spacing: 12) {
                        Button { showEdit = true } label: {
                            HStack(spacing: 8) {
                                WeaverEditIcon(size: 18, color: WeaverTheme.textPrimary)
                                Text("Edit").font(.system(size: 15, weight: .medium)).foregroundColor(WeaverTheme.textPrimary)
                            }
                            .frame(maxWidth: .infinity).frame(height: 48)
                            .background(WeaverTheme.panelRaised)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)

                        Button { showDeleteConfirm = true } label: {
                            HStack(spacing: 8) {
                                WeaverTrashIcon(size: 18, color: Color(red: 1.0, green: 0.55, blue: 0.55))
                                Text("Delete").font(.system(size: 15, weight: .medium)).foregroundColor(Color(red: 1.0, green: 0.55, blue: 0.55))
                            }
                            .frame(maxWidth: .infinity).frame(height: 48)
                            .background(WeaverTheme.panelRaised)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 24)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button { presentationMode.wrappedValue.dismiss() } label: {
                    HStack(spacing: 4) {
                        WeaverBackIcon(size: 20, color: WeaverTheme.line)
                        Text("Atlas").foregroundColor(WeaverTheme.line).font(.system(size: 15))
                    }
                }
            }
        }
        .sheet(isPresented: $showEdit) {
            WeaverEditSheet(constellation: current).environmentObject(store)
        }
        .alert(isPresented: $showDeleteConfirm) {
            Alert(
                title: Text("Delete constellation?"),
                message: Text("“\(current.name)” will be removed from your atlas. This cannot be undone."),
                primaryButton: .destructive(Text("Delete")) {
                    store.delete(current)
                    presentationMode.wrappedValue.dismiss()
                },
                secondaryButton: .cancel())
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label).font(.system(size: 14)).foregroundColor(WeaverTheme.textFaint)
            Spacer()
            Text(value).font(.system(size: 14, weight: .medium)).foregroundColor(WeaverTheme.textSecondary)
        }
    }

    private static let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.locale = Locale(identifier: "en_US")
        f.dateStyle = .medium
        f.timeStyle = .none
        return f
    }()
}
