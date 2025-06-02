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

    /// Creates a view from a given toast model.
    public init(toast: Toast) {
        image = toast.image
        text = toast.text
        style = toast.style
    }

    public var body: some View {
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
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(style.backgroundColor, in: .rect(cornerRadius: style.cornerRadius))
        .shadow(style.shadow)
        .padding(style.padding)
    }

}

// MARK: - Preview

#Preview {
    ToastView(toast: .example)
}
