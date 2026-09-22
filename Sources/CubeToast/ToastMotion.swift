//
//  ToastMotion.swift
//  CubeToast
//
//  Created by Szuyun on 20/09/2026.
//

import SwiftUI
import UIKit

/// Animation parameters shared by the UIKit and SwiftUI renderers, resolved against Reduce Motion.
struct ToastMotion {
    /// Whether the system Reduce Motion setting is on.
    let reduceMotion: Bool

    /// Motion for the current system setting.
    @MainActor static var current: ToastMotion {
        ToastMotion(reduceMotion: UIAccessibility.isReduceMotionEnabled)
    }

    // MARK: - Timing

    /// The fade used in place of movement under Reduce Motion.
    private static let crossFadeDuration: TimeInterval = 0.25
    /// The spring entrance.
    private static let springEntranceDuration: TimeInterval = 0.8
    private static let springDamping: CGFloat = 0.6
    private static let springInitialVelocity: CGFloat = 0.5
    private static let springExtraBounce = 0.2
    /// The slide-down exit.
    private static let slideExitDuration: TimeInterval = 0.5
    private static let slideExitOffset: CGFloat = 200

    // MARK: - UIKit

    /// Whether the entrance slides up from below (otherwise it only fades).
    var slidesOnEntrance: Bool { !reduceMotion }

    /// Duration of the exit animation.
    var exitDuration: TimeInterval { reduceMotion ? Self.crossFadeDuration : Self.slideExitDuration }

    /// Duration of the re-layout when stacked toasts close a gap; matches the exit.
    var reflowDuration: TimeInterval { exitDuration }

    @MainActor
    func animateEntrance(_ changes: @escaping () -> Void) {
        if reduceMotion {
            // No slide under Reduce Motion, so this is a short cross-fade rather than a pop-in.
            UIView.animate(withDuration: Self.crossFadeDuration, animations: changes)
        } else {
            UIView.animate(
                withDuration: Self.springEntranceDuration,
                delay: 0,
                usingSpringWithDamping: Self.springDamping,
                initialSpringVelocity: Self.springInitialVelocity,
                options: [],
                animations: changes
            )
        }
    }

    @MainActor
    func animateExit(_ changes: @escaping () -> Void, completion: @escaping () -> Void) {
        UIView.animate(
            withDuration: exitDuration,
            animations: changes,
            completion: { _ in completion() }
        )
    }

    @MainActor
    func animateReflow(_ changes: @escaping () -> Void) {
        UIView.animate(
            withDuration: reflowDuration,
            delay: 0,
            options: [.beginFromCurrentState],
            animations: changes
        )
    }

    // MARK: - SwiftUI

    /// Animation applied when a toast appears.
    var entrance: Animation {
        reduceMotion ? .easeOut(duration: Self.crossFadeDuration) : .bouncy(extraBounce: Self.springExtraBounce)
    }

    /// Animation applied when a toast leaves.
    var exit: Animation {
        reduceMotion ? .easeOut(duration: Self.crossFadeDuration) : .easeIn
    }

    /// Transition for a toast entering or leaving a stack.
    var transition: AnyTransition {
        reduceMotion ? .opacity : .move(edge: .bottom).combined(with: .opacity)
    }

    /// Vertical offset a single toast travels while dismissing.
    var exitOffset: CGFloat { reduceMotion ? 0 : Self.slideExitOffset }
}
