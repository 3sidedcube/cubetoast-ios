//
//  ToastView.swift
//  CubeToast
//
//  Created by Sam Davis on 02/06/2025.
//

import SwiftUI
import CubeFoundationSwiftUI

/// View describing the appearance of a toast message.
public struct ToastView: View {

    /// Image to be displayed in the toast.
    public let image: ToastImage
    /// Message text shown to the user.
    public let text: String
    /// Visual style applied to this view.
    public let style: ToastStyle
    /// Optional trailing action.
    public let action: ToastAction?
    /// Called when the action asks for the toast to be dismissed.
    var onDismissRequested: (() -> Void)?

    /// Smallest comfortable tap target (HIG).
    private static let minimumHitHeight: CGFloat = 44

    /// Creates a view from a given toast model.
    public init(toast: Toast) {
        image = toast.image
        text = toast.text
        style = toast.style
        action = toast.action
    }

    init(toast: Toast, onDismissRequested: @escaping () -> Void) {
        self.init(toast: toast)
        self.onDismissRequested = onDismissRequested
    }

    public var body: some View {
        if action?.isDismiss == true {
            row.accessibilityAction(.escape) { onDismissRequested?() }
        } else {
            row
        }
    }

    private var row: some View {
        HStack(spacing: 12) {
            Group {
                switch image {
                case .sfSymbol(let symbolName):
                    Image(systemName: symbolName)
                        .foregroundStyle(style.textColor)
                case .resource(let resource):
                    Image(resource)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(size: style.imageSize)
            .background(style.accentColor, in: .circle)

            Text(text)
                .style(style.textStyle)
                .foregroundStyle(style.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)

            if let action {
                actionLink(action)
            }
        }
        .padding(style.insets)
        .background(style.backgroundColor, in: .rect(cornerRadius: style.cornerRadius))
        .shadow(style.shadow)
        .padding(style.padding)
    }
}

// MARK: - Private

private extension ToastView {
    func actionLink(_ action: ToastAction) -> some View {
        Button {
            action.handler()
            if action.dismissesOnTap {
                onDismissRequested?()
            }
        } label: {
            action.label()
                .style(style.textStyle)
                .foregroundStyle(style.textColor)
                .fixedSize(horizontal: true, vertical: false)
                // A 44pt tap target that lays out at the icon's height, so the row stays as tall as the icon.
                .frame(minHeight: Self.minimumHitHeight)
                .padding(.vertical, min(0, (style.imageSize - Self.minimumHitHeight) / 2))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ToastView(toast: .example)
}
