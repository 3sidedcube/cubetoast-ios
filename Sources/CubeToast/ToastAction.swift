//
//  ToastAction.swift
//  CubeToast
//
//  Created by Szuyun on 20/09/2026.
//

import SwiftUI

/// A trailing action on a toast.
public struct ToastAction {
    /// Whether the toast dismisses after the handler runs.
    public var dismissesOnTap: Bool
    /// Work performed when the action is tapped.
    public let handler: @MainActor () -> Void
    /// The label to draw, in the toast's text colour and style.
    let label: () -> AnyView
    /// Marks `.dismiss`, which also gets the VoiceOver escape gesture.
    var isDismiss = false

    /// Creates an action.
    /// - Parameters:
    ///   - dismissesOnTap: Whether the toast dismisses after the handler runs. Defaults to `true`.
    ///   - handler: Work performed when the label is tapped.
    ///   - label: The label to draw.
    public init<Label: View>(
        dismissesOnTap: Bool = true,
        handler: @escaping @MainActor () -> Void,
        @ViewBuilder label: @escaping () -> Label
    ) {
        self.dismissesOnTap = dismissesOnTap
        self.handler = handler
        self.label = { AnyView(label()) }
    }

    /// An action that only dismisses the toast, drawn as an underlined link.
    public static func dismiss(title: String = "Dismiss") -> ToastAction {
        var action = ToastAction(handler: {}) {
            Text(title).underline()
        }
        action.isDismiss = true
        return action
    }
}
