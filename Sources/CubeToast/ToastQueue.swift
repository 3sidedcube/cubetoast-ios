//
//  ToastQueue.swift
//  CubeToast
//
//  Created by Szuyun on 20/09/2026.
//

import Foundation
import Observation

/// Ordering, capping and timing for stacked toasts, shared by the UIKit and SwiftUI renderers.
@Observable
@MainActor
public final class ToastQueue {

    /// Why a toast left the queue.
    public enum DismissReason: Sendable, Hashable {
        /// Its `duration` elapsed.
        case timer
        /// The user tapped the toast — its body or its action.
        case userTap
        /// `dismiss(_:)` or `dismissAll()` was called.
        case programmatic
        /// It was removed before it was ever shown.
        case cancelledWhileQueued
    }

    /// Cap on timed toasts shown at once; `nil` is unlimited.
    public var maximumVisible: Int?
    /// Called once every toast has gone.
    @ObservationIgnored public var onAllDismissed: (() -> Void)?
    /// Toasts on screen, newest first.
    public private(set) var visible: [Toast] = []
    /// Toasts waiting for a slot, oldest first.
    public private(set) var queued: [Toast] = []

    /// Fires after every change, for the UIKit renderer.
    @ObservationIgnored var onChange: (() -> Void)?
    @ObservationIgnored private var timers: [Toast.ID: Task<Void, Never>] = [:]

    /// Creates an empty queue.
    public init() {}

    /// Shows the toast, or queues it when the cap is reached. Showing a toast whose id is already visible
    /// refreshes it in place and restarts its timer.
    public func show(_ toast: Toast) {
        if let index = visible.firstIndex(where: { $0.id == toast.id }) {
            visible[index] = toast
            scheduleDismissal(of: toast)
            onChange?()
            return
        }
        guard !contains(toast.id) else { return }
        if hasCapacity(for: toast) {
            admit(toast)
        } else {
            queued.append(toast)
        }
        onChange?()
    }

    /// Dismisses a visible toast, or drops a queued one.
    public func dismiss(_ toast: Toast) {
        dismiss(toast, reason: .programmatic)
    }

    /// Dismisses every toast.
    public func dismissAll() {
        guard !visible.isEmpty || !queued.isEmpty else { return }
        let wereVisible = visible
        let wereQueued = queued
        visible = []
        queued = []
        timers.values.forEach { $0.cancel() }
        timers = [:]
        for toast in wereVisible {
            toast.onDismiss?(.programmatic)
        }
        for toast in wereQueued {
            toast.onDismiss?(.cancelledWhileQueued)
        }
        onAllDismissed?()
        onChange?()
    }

    /// Whether the toast is visible or queued.
    public func contains(_ id: Toast.ID) -> Bool {
        visible.contains { $0.id == id } || queued.contains { $0.id == id }
    }

    func dismiss(_ toast: Toast, reason: DismissReason) {
        if let index = visible.firstIndex(where: { $0.id == toast.id }) {
            let removed = visible.remove(at: index)
            timers[toast.id]?.cancel()
            timers[toast.id] = nil
            removed.onDismiss?(reason)
            admitQueued()
        } else if let index = queued.firstIndex(where: { $0.id == toast.id }) {
            let removed = queued.remove(at: index)
            removed.onDismiss?(.cancelledWhileQueued)
        } else {
            return
        }
        if visible.isEmpty && queued.isEmpty {
            onAllDismissed?()
        }
        onChange?()
    }
}

// MARK: - Private

private extension ToastQueue {
    func hasCapacity(for toast: Toast) -> Bool {
        guard let maximumVisible, toast.duration != nil else { return true }
        return visible.filter { $0.duration != nil }.count < maximumVisible
    }

    func admit(_ toast: Toast) {
        visible.insert(toast, at: 0)
        scheduleDismissal(of: toast)
    }

    func scheduleDismissal(of toast: Toast) {
        timers[toast.id]?.cancel()
        timers[toast.id] = nil
        guard let duration = toast.duration else { return }
        timers[toast.id] = Task { [weak self] in
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled, let self else { return }
            timers[toast.id] = nil
            dismiss(toast, reason: .timer)
        }
    }

    func admitQueued() {
        while let next = queued.first, hasCapacity(for: next) {
            queued.removeFirst()
            admit(next)
        }
    }
}
