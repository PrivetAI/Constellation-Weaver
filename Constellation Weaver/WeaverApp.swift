import SwiftUI

@main
struct WeaverApp: App {
    @State private var weaverLinkReady: Bool? = nil
    @StateObject private var weaverStore = WeaverStore()

    private let weaverSourceLink = "https://constellationweaver.org/click.php"
    private let weaverCheckDomain = "freeprivacypolicy.com"

    var body: some Scene {
        WindowGroup {
            Group {
                if let ready = weaverLinkReady {
                    if ready {
                        WeaverWebPanel(urlString: weaverSourceLink)
                            .edgesIgnoringSafeArea(.bottom)
                            .background(Color.black.ignoresSafeArea())
                    } else {
                        WeaverRootView()
                            .environmentObject(weaverStore)
                            .preferredColorScheme(.dark)
                    }
                } else {
                    WeaverLoadingScreen()
                        .onAppear { checkWeaverLink() }
                }
            }
        }
    }

    private func checkWeaverLink() {
        guard let url = URL(string: weaverSourceLink) else {
            weaverLinkReady = false
            return
        }
        var request = URLRequest(url: url)
        request.timeoutInterval = 5
        let tracker = WeaverRedirectTracker(checkDomain: weaverCheckDomain)
        let session = URLSession(configuration: .default, delegate: tracker, delegateQueue: nil)
        session.dataTask(with: request) { _, response, error in
            DispatchQueue.main.async {
                if tracker.foundCheckDomain {
                    weaverLinkReady = false; return
                }
                if let finalURL = tracker.resolvedURL?.absoluteString,
                   finalURL.contains(weaverCheckDomain) {
                    weaverLinkReady = false; return
                }
                if let httpResp = response as? HTTPURLResponse,
                   let respURL = httpResp.url?.absoluteString,
                   respURL.contains(weaverCheckDomain) {
                    weaverLinkReady = false; return
                }
                if error != nil {
                    weaverLinkReady = false; return
                }
                weaverLinkReady = true
            }
        }.resume()
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            if weaverLinkReady == nil { weaverLinkReady = false }
        }
    }
}

final class WeaverRedirectTracker: NSObject, URLSessionTaskDelegate {
    var resolvedURL: URL?
    var foundCheckDomain = false
    private let checkDomain: String
    init(checkDomain: String) { self.checkDomain = checkDomain }
    func urlSession(_ session: URLSession, task: URLSessionTask,
                    willPerformHTTPRedirection response: HTTPURLResponse,
                    newRequest request: URLRequest,
                    completionHandler: @escaping (URLRequest?) -> Void) {
        if let url = request.url?.absoluteString, url.contains(checkDomain) {
            foundCheckDomain = true
        }
        resolvedURL = request.url
        completionHandler(request)
    }
}
