//
//  ToastModifier.swift
//  CubeToast
//
//  Created by Sam Davis on 02/06/2025.
//

import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var toast: Toast?
    @State private var isPresented = false

    func body(content: Content) -> some View {
        ZStack(alignment: .bottom) {
            content
            if let toast = toast, isPresented {
                ToastView(toast: toast)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .onTapGesture { dismiss() }
            }
        }
        .onChange(of: toast) { _, value in
            if value != nil {
                withAnimation(.bouncy(extraBounce: 0.2)) {
                    isPresented = true
                }
                scheduleDismiss()
            } else if isPresented {
                dismiss()
            }
        }
    }

    private func scheduleDismiss() {
        guard let duration = toast?.duration else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            dismiss()
        }
    }

    private func dismiss() {
        withAnimation(.easeIn) {
            isPresented = false
        }
        toast = nil
    }
}

public extension View {
    /// Presents a toast bound to the given binding.
    func toast(_ toast: Binding<Toast?>) -> some View {
        modifier(ToastModifier(toast: toast))
    }
}

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
