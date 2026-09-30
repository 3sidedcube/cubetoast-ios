//
//  ToastWindow.swift
//  CubeToast
//
//  Created by Szuyun on 20/09/2026.
//

import SwiftUI
import UIKit

/// Transparent `.alert`-level window that stacks toasts above every modal presentation.
///
/// The window lays its toasts out: `bottomInset`, `leadingInset` and `trailingInset` place the stack, so a
/// toast's `style.padding` applies vertically only — however it reached the queue. The stack is `.toasts(_:)`
/// hosted once, sized to its content so touches beside or above the toasts fall through.
public final class ToastWindow: UIWindow {

    /// The queue behind the window's toasts.
    public let queue: ToastQueue

    /// Distance the toasts keep from the bottom edge, e.g. a tab bar's height.
    public var bottomInset: CGFloat = 0 {
        didSet { stackBottom.constant = -bottomInset }
    }

    /// Distance the toasts keep from the leading edge.
    public var leadingInset: CGFloat = 0 {
        didSet { stackLeading.constant = leadingInset }
    }

    /// Distance the toasts keep from the trailing edge.
    public var trailingInset: CGFloat = 0 {
        didSet { stackTrailing.constant = -trailingInset }
    }

    private let stackBottom: NSLayoutConstraint
    private let stackLeading: NSLayoutConstraint
    private let stackTrailing: NSLayoutConstraint
    private let stackHeight: NSLayoutConstraint

    /// Creates a visible window on the scene for the given queue.
    public init(windowScene: UIWindowScene, queue: ToastQueue = ToastQueue()) {
        self.queue = queue
        let root = ToastWindowRootViewController()
        let height = StackHeight()
        // `EmptyView` keeps the stack sized to the toasts (a colour would fill the hosting view); the reported height
        // sizes the hosting view, so `hitTest` can pass everything around the toasts through.
        let hosting = UIHostingController(
            rootView: EmptyView()
                .toasts(queue)
                .environment(\.toastAppliesSidePadding, false)
                .fixedSize(horizontal: false, vertical: true)
                .onGeometryChange(for: CGFloat.self) { $0.size.height } action: { height.onChange?($0) }
        )
        hosting.safeAreaRegions = []
        hosting.view.backgroundColor = .clear
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        stackBottom = hosting.view.bottomAnchor.constraint(equalTo: root.view.bottomAnchor)
        stackLeading = hosting.view.leadingAnchor.constraint(equalTo: root.view.leadingAnchor)
        stackTrailing = hosting.view.trailingAnchor.constraint(equalTo: root.view.trailingAnchor)
        stackHeight = hosting.view.heightAnchor.constraint(equalToConstant: 0)
        super.init(windowScene: windowScene)
        windowLevel = .alert
        backgroundColor = .clear
        isHidden = false
        rootViewController = root

        root.addChild(hosting)
        root.view.addSubview(hosting.view)
        hosting.didMove(toParent: root)
        NSLayoutConstraint.activate([stackLeading, stackTrailing, stackBottom, stackHeight])
        // An empty stack still measures a few points; collapse it so nothing intercepts touches between toasts.
        height.onChange = { [weak self] height in
            guard let self else { return }
            stackHeight.constant = queue.visible.isEmpty ? 0 : height
        }
    }

    /// This class does not support interface builder initialisation.
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Shows the toast.
    public func show(_ toast: Toast) {
        queue.show(toast)
    }

    /// Dismisses the toast.
    public func dismiss(_ toast: Toast) {
        queue.dismiss(toast)
    }

    /// Dismisses every toast.
    public func dismissAll() {
        queue.dismissAll()
    }

    /// Touches that miss the stack fall through to the windows below.
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if hit === self || hit === rootViewController?.view {
            return nil
        }
        return hit
    }
}

/// Relays the stack's measured height to the window's height constraint.
private final class StackHeight {
    var onChange: ((CGFloat) -> Void)?
}

private final class ToastWindowRootViewController: UIViewController {
    override func loadView() {
        let root = UIView()
        root.backgroundColor = .clear
        view = root
    }

    override var childForStatusBarStyle: UIViewController? { nil }

    override var childForStatusBarHidden: UIViewController? { nil }
}

// MARK: - Preview

/// Preview controller: each tap stacks another toast in a real `ToastWindow`.
private final class ToastWindow_Preview: UIViewController {

    private var toastWindow: ToastWindow?
    private var shown = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        let button = UIButton(type: .system)
        button.setTitle("Show Toast", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .medium)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(showToastButtonTapped), for: .touchUpInside)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // The scene only exists once this controller is on screen.
        guard toastWindow == nil, let scene = view.window?.windowScene else { return }
        let window = ToastWindow(windowScene: scene)
        window.bottomInset = view.safeAreaInsets.bottom
        toastWindow = window
    }

    @objc private func showToastButtonTapped() {
        shown += 1
        toastWindow?.show(.init(
            image: .sfSymbol("bubble.middle.bottom.fill"),
            text: "Slice of toast number \(shown).",
            style: .example
        ))
    }
}

#Preview {
    ToastWindow_Preview()
}
