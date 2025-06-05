//
//  ToastStyle.swift
//  CubeToast
//
//  Created by Sam Davis on 02/06/2025.
//

import SwiftUI
import CubeFoundationSwiftUI

/// Visual styling information for a toast message.
public struct ToastStyle: Equatable {
    /// Background colour for the toast view.
    public var backgroundColor: Color
    /// Accent colour used behind the image.
    public var accentColor: Color
    /// Colour of the text.
    public var textColor: Color
    /// Typography used for the message text.
    public var textStyle: TextStyle
    /// Corner radius applied to the toast.
    public var cornerRadius: CGFloat
    /// Content inset of the toast
    public var insets: EdgeInsets
    /// Padding around the toast.
    public var padding: EdgeInsets
    /// Size of the leading image.
    public var imageSize: CGFloat
    /// Shadow applied to the toast.
    public var shadow: FigmaShadow

    public init(
        backgroundColor: Color,
        accentColor: Color,
        textColor: Color,
        textStyle: TextStyle,
        cornerRadius: CGFloat,
        insets: EdgeInsets,
        padding: EdgeInsets,
        imageSize: CGFloat,
        shadow: FigmaShadow
    ) {
        self.backgroundColor = backgroundColor
        self.accentColor = accentColor
        self.textColor = textColor
        self.textStyle = textStyle
        self.cornerRadius = cornerRadius
        self.insets = insets
        self.padding = padding
        self.imageSize = imageSize
        self.shadow = shadow
    }
}

// MARK: - Example
internal extension ToastStyle {

    /// Default styling used for previews.
    static var example: ToastStyle { .init(
        backgroundColor: .black.opacity(0.89),
        accentColor: .orange,
        textColor: .white,
        textStyle: .init(.system, weight: .regular, size: 13, lineHeight: 20, letter: 0.2),
        cornerRadius: 16,
        insets: .init(top: 12, leading: 12, bottom: 12, trailing: 12),
        padding: .init(top: 16, leading: 20, bottom: 16, trailing: 20),
        imageSize: 32,
        shadow: .init(x: 0, y: 0, blur: 8, color: .black.opacity(0.11))
    )}
}
