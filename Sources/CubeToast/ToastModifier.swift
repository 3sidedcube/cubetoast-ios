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

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if let toast = toast, isPresented {
                ToastView(toast: toast)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onTapGesture { dismiss() }
                    .offset(y: dismissAnimation ? 200 : 0)
                    .opacity(dismissAnimation ? 0 : 1)
            }
        }
        .onChange(of: toast) { _, value in
            if let value {
                withAnimation(.bouncy(extraBounce: 0.2)) {
                    isPresented = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                    AccessibilityNotification.Announcement(value.text).post()
                }
                scheduleDismiss()
            } else if isPresented {
                dismiss()
            }
        }
        .onDisappear {
            dismissTimer?.cancel()
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
            dismiss()
        }
    }

    /// Dismisses the toast immediately.
    private func dismiss() {
        withAnimation(.easeIn) {
            dismissAnimation = true
        } completion: {
            isPresented = false
            dismissAnimation = false
            toast = nil
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
