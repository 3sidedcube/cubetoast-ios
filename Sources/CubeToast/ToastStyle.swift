//
//  ToastStyle.swift
//  CubeToast
//
//  Created by Sam Davis on 02/06/2025.
//

import SwiftUI
import CubeFoundationSwiftUI

struct ToastStyle {
    var backgroundColor: Color
    var accentColor: Color
    var textColor: Color
    var textStyle: TextStyle
    var cornerRadius: CGFloat
    var padding: EdgeInsets
    var imageSize: CGFloat
    var shadow: FigmaShadow
}

extension ToastStyle {

    static var `default`: ToastStyle { .init(
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
