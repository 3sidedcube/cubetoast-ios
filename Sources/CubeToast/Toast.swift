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
    /// Whether VoiceOver moves onto the toast as it appears, instead of hearing it announced. For a toast that
    /// confirms the user's own action, where whatever VoiceOver would read next is out of date.
    public var focusesVoiceOver: Bool
    /// Called once when the toast is dismissed.
    public var onDismiss: (@MainActor (ToastQueue.DismissReason) -> Void)?

    /// New each time the toast is shown, a refresh in place included, so a refreshed toast takes VoiceOver again.
    var presentationID = UUID()

    /// Creates a new toast.
    /// - Parameters:
    ///   - id: Identity of the toast. A fixed id lets several callers show the same toast and have the
    ///     queue keep one, or dismiss it later without holding the value.
    ///   - image: The image to show with the message.
    ///   - text: The message text.
    ///   - style: The visual style for the toast.
    ///   - duration: Optional auto-dismiss duration. Defaults to three seconds.
    ///   - action: Optional trailing action.
    ///   - announcementPriority: VoiceOver priority. Defaults to `.low`.
    ///   - focusesVoiceOver: Whether VoiceOver moves onto the toast instead of announcing it. Defaults to `false`.
    ///   - onDismiss: Called once when the toast is dismissed.
    public init(
        id: UUID = UUID(),
        image: ToastImage,
        text: String,
        style: ToastStyle,
        duration: TimeInterval? = 3.0,
        action: ToastAction? = nil,
        announcementPriority: UIAccessibilityPriority = .low,
        focusesVoiceOver: Bool = false,
        onDismiss: (@MainActor (ToastQueue.DismissReason) -> Void)? = nil
    ) {
        self.id = id
        self.image = image
        self.text = text
        self.duration = duration
        self.style = style
        self.action = action
        self.announcementPriority = announcementPriority
        self.focusesVoiceOver = focusesVoiceOver
        self.onDismiss = onDismiss
    }

    /// Identity comparison, so closures can live on the model.
    public static func == (lhs: Toast, rhs: Toast) -> Bool {
        lhs.id == rhs.id
    }
}

extension Toast {
    /// How long the toast stays before dismissing itself, or `nil` when it stays until dismissed.
    ///
    /// A toast with an action stays while VoiceOver is running. VoiceOver hears the announcement but not the action,
    /// and reaching it can take longer than the timer, or wait on a modal such as a tip being closed first.
    @MainActor var displayDuration: TimeInterval? {
        action != nil && UIAccessibility.isVoiceOverRunning ? nil : duration
    }

    /// Announces the text to VoiceOver after the entrance animation. A toast that takes VoiceOver's focus is read
    /// out from there instead (`ToastView`), and announcing it too would read it twice.
    @MainActor
    func announce() {
        guard !focusesVoiceOver else { return }
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
