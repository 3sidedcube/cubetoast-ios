//
//  ToastContainerView.swift
//  CubeToast
//
//  Created by Sam Davis on 02/06/2025.
//

import UIKit
import SwiftUI

/// View that can present toast messages in UIKit.
public final class ToastContainerView: UIView {

    private var hostingController: UIHostingController<HostedToast>?
    private var currentToast: Toast?

    /// Height of the toast on screen, including its padding.
    var visibleToastHeight: CGFloat {
        hostingController?.view.bounds.height ?? 0
    }

    /// Receives taps on the toast; when unset the container dismisses it.
    var onInteraction: ((Toast, ToastQueue.DismissReason) -> Void)?

    /// Creates a new container ready to display toasts.
    public override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }

    /// This class does not support interface builder initialisation.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Only the toast takes touches; the rest falls through.
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hit = super.hitTest(point, with: event)
        return hit === self ? nil : hit
    }

    /// Presents the given toast.
    public func show(_ toast: Toast) {
        dismissCurrent()
        currentToast = toast

        let view = HostedToast(
            toast: toast,
            onTap: { [weak self] in self?.handleInteraction(.userTap) },
            onDismissRequested: { [weak self] in self?.handleInteraction(.userTap) }
        )
        let host = UIHostingController(rootView: view)
        host.view.translatesAutoresizingMaskIntoConstraints = false
        host.view.backgroundColor = .clear

        addSubview(host.view)
        NSLayoutConstraint.activate([
            host.view.leadingAnchor.constraint(equalTo: leadingAnchor),
            host.view.trailingAnchor.constraint(equalTo: trailingAnchor),
            host.view.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        hostingController = host
        layoutIfNeeded()

        toast.announce()

        let motion = ToastMotion.current
        if motion.slidesOnEntrance {
            host.view.transform = CGAffineTransform(translationX: 0, y: host.view.bounds.height)
        }
        host.view.alpha = 0
        motion.animateEntrance {
            host.view.transform = .identity
            host.view.alpha = 1
        }

        if let duration = toast.duration {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                guard self?.currentToast?.id == toast.id else { return }
                self?.dismissCurrent(reason: .timer)
            }
        }
    }

    /// Dismisses any currently displayed toast.
    public func dismissCurrent() {
        dismissCurrent(reason: .programmatic)
    }
}

// MARK: - Private

private extension ToastContainerView {
    func dismissCurrent(reason: ToastQueue.DismissReason) {
        guard let host = hostingController else { return }
        let toast = currentToast
        let motion = ToastMotion.current
        motion.animateExit({
            if motion.slidesOnEntrance {
                host.view.transform = CGAffineTransform(translationX: 0, y: host.view.bounds.height)
            }
            host.view.alpha = 0
        }, completion: {
            host.view.removeFromSuperview()
        })
        hostingController = nil
        currentToast = nil
        toast?.onDismiss?(reason)
    }

    func handleInteraction(_ reason: ToastQueue.DismissReason) {
        guard let toast = currentToast else { return }
        if let onInteraction {
            onInteraction(toast, reason)
        } else {
            dismissCurrent(reason: reason)
        }
    }
}

/// The toast view with its tap wired to the container.
struct HostedToast: View {
    let toast: Toast
    let onTap: () -> Void
    let onDismissRequested: () -> Void

    var body: some View {
        ToastView(toast: toast, onDismissRequested: onDismissRequested)
            .onTapGesture(perform: onTap)
    }
}

// MARK: - Preview

/// Preview controller showcasing the toast container.
private class ToastContainerView_Preview: UIViewController {

    private let toastContainer = ToastContainerView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        view.addSubview(toastContainer)
        toastContainer.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            toastContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toastContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toastContainer.topAnchor.constraint(equalTo: view.topAnchor),
            toastContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

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

    @objc private func showToastButtonTapped() {
        toastContainer.show(.example)
    }
}

#Preview {
    ToastContainerView_Preview()
}
