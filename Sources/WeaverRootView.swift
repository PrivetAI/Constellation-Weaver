import SwiftUI

struct WeaverRootView: View {
    @EnvironmentObject var store: WeaverStore
    @State private var selectedTab = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            WeaverTheme.backgroundGradient.ignoresSafeArea()

            VStack(spacing: 0) {
                Group {
                    switch selectedTab {
                    case 0:
                        NavigationView { WeaverSkiesView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    case 1:
                        NavigationView { WeaverAtlasView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    default:
                        NavigationView { WeaverSettingsView() }
                            .navigationViewStyle(StackNavigationViewStyle())
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)

                tabBar
            }
        }
    }

    private var tabBar: some View {
        HStack(spacing: 0) {
            tabButton(index: 0, label: "Skies",
                      icon: AnyView(WeaverSkiesIcon(size: 24, color: tint(0))))
            tabButton(index: 1, label: "Atlas",
                      icon: AnyView(WeaverAtlasIcon(size: 24, color: tint(1))))
            tabButton(index: 2, label: "Settings",
                      icon: AnyView(WeaverSettingsIcon(size: 24, color: tint(2))))
        }
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(
            WeaverTheme.panel
                .overlay(Rectangle().frame(height: 1).foregroundColor(WeaverTheme.stroke.opacity(0.5)), alignment: .top)
                .edgesIgnoringSafeArea(.bottom)
        )
    }

    private func tint(_ index: Int) -> Color {
        selectedTab == index ? WeaverTheme.line : WeaverTheme.textFaint
    }

    private func tabButton(index: Int, label: String, icon: AnyView) -> some View {
        Button {
            selectedTab = index
        } label: {
            VStack(spacing: 5) {
                icon.frame(height: 26)
                Text(label)
                    .font(.system(size: 11, weight: selectedTab == index ? .semibold : .regular))
                    .foregroundColor(tint(index))
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}
