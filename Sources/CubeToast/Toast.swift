//
//  Toast.swift
//  CubeToast
//
//  Created by Sam Davis on 02/06/2025.
//

import Foundation
import SwiftUI

/// Model representing a toast message.
public struct Toast: Identifiable, Equatable {
    /// Unique identifier for this toast.
    public let id: UUID
    /// Image shown alongside the text.
    public var image: ToastImage
    /// Message displayed to the user.
    public var text: String
    /// Visual style applied to the toast.
    public var style: ToastStyle
    /// Optional time after which the toast dismisses automatically.
    public var duration: TimeInterval?

    /// Creates a new toast.
    /// - Parameters:
    ///   - image: The image to show with the message.
    ///   - text: The message text.
    ///   - style: The visual style for the toast.
    ///   - duration: Optional auto-dismiss duration. Defaults to three seconds.
    public init(image: ToastImage, text: String, style: ToastStyle, duration: TimeInterval? = 3.0) {
        self.id = UUID()
        self.image = image
        self.text = text
        self.duration = duration
        self.style = style
    }
}

// MARK: - Toast + Example

internal extension Toast {

    /// A sample toast used in previews.
    static var example: Toast {
        .init(
            image: .sfSymbol("bubble.middle.bottom.fill"),
            text: "A lovely slice of buttered toast.",
            style: .example
        )
    }
}
