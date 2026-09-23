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
/// hosted toast's `style.padding` applies vertically only.
public final class ToastWindow: UIWindow {

    /// The queue behind the window's toasts.
    public var queue: ToastQueue { stack.queue }

    let stack: ToastStackView

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

    /// Creates a visible window on the scene for the given queue.
    public init(windowScene: UIWindowScene, queue: ToastQueue = ToastQueue()) {
        let stack = ToastStackView(queue: queue)
        self.stack = stack
        let root = ToastWindowRootViewController()
        stackBottom = stack.bottomAnchor.constraint(equalTo: root.view.bottomAnchor)
        stackLeading = stack.leadingAnchor.constraint(equalTo: root.view.leadingAnchor)
        stackTrailing = stack.trailingAnchor.constraint(equalTo: root.view.trailingAnchor)
        super.init(windowScene: windowScene)
        windowLevel = .alert
        backgroundColor = .clear
        isHidden = false
        rootViewController = root

        root.view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: root.view.topAnchor),
            stackLeading,
            stackTrailing,
            stackBottom
        ])
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

    /// Touches that miss a toast fall through to the windows below.
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        if hit === self || hit === rootViewController?.view {
            return nil
        }
        return hit
    }
}

// MARK: - Stack

/// UIKit renderer for a `ToastQueue`: one `ToastContainerView` per visible toast, stacked by bottom inset.
final class ToastStackView: UIView {

    /// The queue this view renders.
    let queue: ToastQueue

    private var containers: [Toast.ID: ToastContainerView] = [:]
    private var bottomConstraints: [Toast.ID: NSLayoutConstraint] = [:]

    /// Creates a stack rendering the given queue.
    init(queue: ToastQueue = ToastQueue()) {
        self.queue = queue
        super.init(frame: .zero)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
        queue.onChange = { [weak self] in self?.render() }
    }

    /// This class does not support interface builder initialisation.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Only the toasts take touches; the rest falls through.
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return hit === self ? nil : hit
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        applyInsets(animated: false)
    }
}

// MARK: - Private

private extension ToastStackView {
    func render() {
        let visible = queue.visible
        let visibleIDs = Set(visible.map(\.id))
        for id in containers.keys where !visibleIDs.contains(id) {
            retire(id)
        }
        // Bottom-up, so each toast can read the heights below it.
        for toast in visible.reversed() where containers[toast.id] == nil {
            insert(toast)
        }
        applyInsets(animated: true)
    }

    func insert(_ toast: Toast) {
        let container = ToastContainerView()
        container.onInteraction = { [weak self] _, reason in
            self?.queue.dismiss(toast, reason: reason)
        }
        addSubview(container)
        let bottom = container.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -inset(for: toast.id))
        NSLayoutConstraint.activate([
            container.topAnchor.constraint(equalTo: topAnchor),
            container.leadingAnchor.constraint(equalTo: leadingAnchor),
            container.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottom
        ])
        containers[toast.id] = container
        bottomConstraints[toast.id] = bottom
        layoutIfNeeded()

        // The queue owns timing and the dismiss callback; the container only draws. The stack's owner
        // places it horizontally (see `ToastWindow`), so the style's side padding does not apply here.
        var hosted = toast
        hosted.duration = nil
        hosted.onDismiss = nil
        hosted.style.padding.leading = 0
        hosted.style.padding.trailing = 0
        container.show(hosted)
    }

    func retire(_ id: Toast.ID) {
        guard let container = containers.removeValue(forKey: id) else { return }
        bottomConstraints[id] = nil
        container.dismissCurrent()
        DispatchQueue.main.asyncAfter(deadline: .now() + ToastMotion.current.exitDuration) {
            container.removeFromSuperview()
        }
    }

    /// The heights of every toast below this one.
    func inset(for id: Toast.ID) -> CGFloat {
        let visible = queue.visible
        guard let index = visible.firstIndex(where: { $0.id == id }) else { return 0 }
        return visible[(index + 1)...].reduce(0) { $0 + (containers[$1.id]?.visibleToastHeight ?? 0) }
    }

    func applyInsets(animated: Bool) {
        var changed = false
        for toast in queue.visible {
            guard let constraint = bottomConstraints[toast.id] else { continue }
            let target = -inset(for: toast.id)
            if constraint.constant != target {
                constraint.constant = target
                changed = true
            }
        }
        guard changed else { return }
        if animated {
            ToastMotion.current.animateReflow { self.layoutIfNeeded() }
        } else {
            setNeedsLayout()
        }
    }
}

// MARK: - Root

/// Transparent root that leaves status-bar appearance to the app.
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
