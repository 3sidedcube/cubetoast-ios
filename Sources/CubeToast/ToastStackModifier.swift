//
//  ToastStackModifier.swift
//  CubeToast
//
//  Created by Szuyun on 20/09/2026.
//

import SwiftUI

/// Modifier that presents a queue's toasts as a stack over the modified content, newest on top.
struct ToastStackModifier: ViewModifier {
    let queue: ToastQueue
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var motion: ToastMotion { ToastMotion(reduceMotion: reduceMotion) }

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            VStack(spacing: 0) {
                ForEach(queue.visible) { toast in
                    ToastView(toast: toast) { queue.dismiss(toast, reason: .userTap) }
                        .toastPresentation(toast) { queue.dismiss(toast, reason: $0) }
                }
            }
            .zIndex(1)
            .animation(motion.entrance, value: queue.visible.map(\.id))
        }
        .onDisappear { queue.dismissAll() }
    }
}

// MARK: - View Extension

public extension View {
    /// Presents the queue's toasts as a stack, newest on top.
    func toasts(_ queue: ToastQueue) -> some View {
        modifier(ToastStackModifier(queue: queue))
    }
}

// MARK: - Preview

#Preview {
    @Previewable @State var queue = ToastQueue()

    Button("Show Toast") {
        queue.show(.example)
    }
    .padding()
    .buttonStyle(.borderedProminent)
    .frame(maxHeight: .infinity)
    .toasts(queue)
}
