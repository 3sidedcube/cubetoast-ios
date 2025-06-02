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
    public var backgroundColor: Color
    public var accentColor: Color
    public var textColor: Color
    public var textStyle: TextStyle
    public var cornerRadius: CGFloat
    public var padding: EdgeInsets
    public var imageSize: CGFloat
    public var shadow: FigmaShadow
}

public extension ToastStyle {

    static var example: ToastStyle { .init(
        backgroundColor: .black.opacity(0.89),
        accentColor: .orange,
        textColor: .white,
        textStyle: .init(.system, weight: .regular, size: 13, lineHeight: 20, letter: 0.2),
        cornerRadius: 16,
        padding: .init(top: 16, leading: 20, bottom: 16, trailing: 20),
        imageSize: 32,
        shadow: .init(x: 0, y: 0, blur: 8, color: .black.opacity(0.11))
    )}
}
