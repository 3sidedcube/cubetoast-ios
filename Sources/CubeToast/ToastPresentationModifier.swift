//
//  ToastPresentationModifier.swift
//  CubeToast
//
//  Created by Szuyun on 22/09/2026.
//

import SwiftUI

/// Behaviour shared by every presented toast: tap to dismiss, transition, VoiceOver announcement.
struct ToastPresentationModifier: ViewModifier {
    let toast: Toast
    let dismiss: (ToastQueue.DismissReason) -> Void
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content
            .onTapGesture { dismiss(.userTap) }
            .transition(ToastMotion(reduceMotion: reduceMotion).transition)
            .onAppear { toast.announce() }
    }
}

extension View {
    /// Applies the shared presentation behaviour to a `ToastView`.
    func toastPresentation(_ toast: Toast, dismiss: @escaping (ToastQueue.DismissReason) -> Void) -> some View {
        modifier(ToastPresentationModifier(toast: toast, dismiss: dismiss))
    }
}
