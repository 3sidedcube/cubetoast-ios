//
//  ToastModifier.swift
//  CubeToast
//
//  Created by Sam Davis on 02/06/2025.
//

import SwiftUI

/// Modifier that presents a toast view over the modified content.
struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?
    @State private var isPresented = false
    @State private var dismissTimer: Task<Void, Never>?
    @State private var dismissAnimation = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var motion: ToastMotion { ToastMotion(reduceMotion: reduceMotion) }

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if let toast = toast, isPresented {
                ToastView(toast: toast) { dismiss(reason: .userTap) }
                    .toastPresentation(toast) { dismiss(reason: $0) }
                    .zIndex(1)
                    .offset(y: dismissAnimation ? motion.exitOffset : 0)
                    .opacity(dismissAnimation ? 0 : 1)
            }
        }
        .onChange(of: toast) { _, value in
            if let value {
                withAnimation(motion.entrance) {
                    isPresented = true
                }
                scheduleDismiss()
            } else if isPresented {
                dismiss(reason: .programmatic)
            }
        }
        .onDisappear {
            dismissTimer?.cancel()
            dismiss(reason: .programmatic)
        }
    }

    /// Schedules the toast to dismiss after its duration elapses.
    private func scheduleDismiss() {
        guard let duration = toast?.duration else { return }

        // Cancel any existing dismiss timer and start a new one to extend the toast display time.
        dismissTimer?.cancel()
        dismissTimer = Task {
            try? await Task.sleep(for: .seconds(duration))
            guard !Task.isCancelled else { return }
            dismiss(reason: .timer)
        }
    }

    /// Dismisses the toast immediately.
    private func dismiss(reason: ToastQueue.DismissReason) {
        let dismissed = toast
        withAnimation(motion.exit) {
            dismissAnimation = true
        } completion: {
            isPresented = false
            dismissAnimation = false
            toast = nil
            dismissed?.onDismiss?(reason)
        }
    }
}

// MARK: - View Extension

public extension View {
    /// Presents a toast bound to the given binding.
    func toast(_ toast: Binding<Toast?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var toast: Toast? = nil

    Button("Show Toast") {
        toast = .example
    }
    .padding()
    .buttonStyle(.borderedProminent)
    .frame(maxHeight: .infinity)
    .toast($toast)
}
