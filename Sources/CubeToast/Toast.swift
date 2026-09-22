//
//  Toast.swift
//  CubeToast
//
//  Created by Sam Davis on 02/06/2025.
//

import Foundation
import SwiftUI
import UIKit

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
    /// Optional trailing action.
    public var action: ToastAction?
    /// VoiceOver priority of the announcement.
    public var announcementPriority: UIAccessibilityPriority
    /// Called once when the toast is dismissed.
    public var onDismiss: (@MainActor (ToastQueue.DismissReason) -> Void)?

    /// Creates a new toast.
    /// - Parameters:
    ///   - image: The image to show with the message.
    ///   - text: The message text.
    ///   - style: The visual style for the toast.
    ///   - duration: Optional auto-dismiss duration. Defaults to three seconds.
    ///   - action: Optional trailing action.
    ///   - announcementPriority: VoiceOver priority. Defaults to `.low`.
    ///   - onDismiss: Called once when the toast is dismissed.
    public init(
        image: ToastImage,
        text: String,
        style: ToastStyle,
        duration: TimeInterval? = 3.0,
        action: ToastAction? = nil,
        announcementPriority: UIAccessibilityPriority = .low,
        onDismiss: (@MainActor (ToastQueue.DismissReason) -> Void)? = nil
    ) {
        self.id = UUID()
        self.image = image
        self.text = text
        self.duration = duration
        self.style = style
        self.action = action
        self.announcementPriority = announcementPriority
        self.onDismiss = onDismiss
    }

    /// Identity comparison, so closures can live on the model.
    public static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }
}

extension Toast {
    /// Announces the text to VoiceOver after the entrance animation.
    @MainActor
    func announce() {
        let announcement = NSAttributedString(
            string: text,
            attributes: [.accessibilitySpeechAnnouncementPriority: announcementPriority.rawValue]
        )
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            UIAccessibility.post(notification: .announcement, argument: announcement)
        }
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
