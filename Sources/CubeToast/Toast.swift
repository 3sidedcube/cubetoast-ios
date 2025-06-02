//
//  Toast.swift
//  CubeToast
//
//  Created by Sam Davis on 02/06/2025.
//

import Foundation
import SwiftUI

public struct Toast: Identifiable, Equatable {
    public let id: UUID
    public var image: ToastImage
    public var text: String
    public var style: ToastStyle
    public var duration: TimeInterval?

    public init(image: ToastImage, text: String, style: ToastStyle, duration: TimeInterval? = 3.0) {
        self.id = UUID()
        self.image = image
        self.text = text
        self.duration = duration
        self.style = style
    }
}

public extension Toast {

    static var example: Toast {
        .init(
            image: .sfSymbol("bubble.middle.bottom.fill"),
            text: "A lovely slice of buttered toast.",
            style: .example
        )
    }
}
