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
    private var hostingController: UIHostingController<ToastView>?
    private var currentToast: Toast?

    public override init(frame: CGRect) {
        super.init(frame: frame)
        translatesAutoresizingMaskIntoConstraints = false
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// Presents the given toast.
    public func show(_ toast: Toast) {
        dismissCurrent()
        currentToast = toast

        let view = ToastView(toast: toast)
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
        host.view.transform = CGAffineTransform(translationX: 0, y: host.view.bounds.height)
        host.view.alpha = 0
        UIView.animate(withDuration: 0.8,
                       delay: 0,
                       usingSpringWithDamping: 0.6,
                       initialSpringVelocity: 0.5,
                       options: [],
                       animations: {
            host.view.transform = .identity
            host.view.alpha = 1
        })

        if let duration = toast.duration {
            DispatchQueue.main.asyncAfter(deadline: .now() + duration) { [weak self] in
                self?.dismissCurrent()
            }
        }
    }

    /// Dismisses any currently displayed toast.
    public func dismissCurrent() {
        guard let host = hostingController else { return }
        UIView.animate(withDuration: 0.5, animations: {
            host.view.transform = CGAffineTransform(translationX: 0, y: host.view.bounds.height)
            host.view.alpha = 0
        }, completion: { _ in
            host.view.removeFromSuperview()
        })
        hostingController = nil
        currentToast = nil
    }
}

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
