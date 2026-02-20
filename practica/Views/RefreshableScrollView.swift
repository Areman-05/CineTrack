import SwiftUI
import UIKit

/// ScrollView con pull-to-refresh compatible con iOS 14.
/// Uso: RefreshableScrollView(isRefreshing: $refreshing, onRefresh: { ... }) { contenido }
struct RefreshableScrollView<Content: View>: View {
    let isRefreshing: Binding<Bool>
    let onRefresh: () -> Void
    let content: Content

    init(isRefreshing: Binding<Bool>, onRefresh: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.isRefreshing = isRefreshing
        self.onRefresh = onRefresh
        self.content = content()
    }

    var body: some View {
        RefreshableScrollViewRepresentable(isRefreshing: isRefreshing, onRefresh: onRefresh, content: content)
    }
}

private struct RefreshableScrollViewRepresentable<Content: View>: UIViewRepresentable {
    let isRefreshing: Binding<Bool>
    let onRefresh: () -> Void
    let content: Content

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(context.coordinator, action: #selector(Coordinator.didPullToRefresh), for: .valueChanged)
        scrollView.backgroundColor = UIColor(red: 0.08, green: 0.08, blue: 0.10, alpha: 1)
        scrollView.alwaysBounceVertical = true

        let hosting = UIHostingController(rootView: content)
        hosting.view.backgroundColor = .clear
        scrollView.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        context.coordinator.hostingController = hosting

        let frameGuide = scrollView.frameLayoutGuide
        let contentGuide = scrollView.contentLayoutGuide
        NSLayoutConstraint.activate([
            hosting.view.leadingAnchor.constraint(equalTo: contentGuide.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: contentGuide.trailingAnchor),
            hosting.view.topAnchor.constraint(equalTo: contentGuide.topAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: contentGuide.bottomAnchor),
            hosting.view.widthAnchor.constraint(equalTo: frameGuide.widthAnchor)
        ])
        context.coordinator.scrollView = scrollView
        return scrollView
    }

    func updateUIView(_ scrollView: UIScrollView, context: Context) {
        context.coordinator.hostingController?.rootView = content
        if !isRefreshing.wrappedValue, context.coordinator.wasRefreshing {
            scrollView.refreshControl?.endRefreshing()
            context.coordinator.wasRefreshing = false
        }
        context.coordinator.wasRefreshing = isRefreshing.wrappedValue
    }

    class Coordinator: NSObject {
        var parent: RefreshableScrollViewRepresentable
        weak var scrollView: UIScrollView?
        var hostingController: UIHostingController<Content>?
        var wasRefreshing = false

        init(_ parent: RefreshableScrollViewRepresentable) {
            self.parent = parent
        }

        @objc func didPullToRefresh() {
            parent.isRefreshing.wrappedValue = true
            parent.onRefresh()
        }
    }
}

