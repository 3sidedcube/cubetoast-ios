//
//  ToastView.swift
//  CubeToast
//
//  Created by Sam Davis on 02/06/2025.
//

import SwiftUI
import UIKit
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
    /// Whether VoiceOver moves onto the message as the toast appears (`Toast.focusesVoiceOver`).
    private let focusesVoiceOver: Bool
    /// The showing this view draws; a new one moves VoiceOver back onto a toast refreshed in place.
    private let presentationID: UUID

    @Environment(\.toastAppliesSidePadding) private var appliesSidePadding
    @AccessibilityFocusState private var isMessageFocused: Bool

    /// Smallest comfortable tap target (HIG).
    private static let minimumHitHeight: CGFloat = 44
    /// How long after the toast claims VoiceOver's focus a move elsewhere counts as VoiceOver's own pick (a sheet
    /// closing lands one about 0.4s later) rather than the user swiping away.
    private static let focusGuardWindow: Duration = .seconds(1)

    /// Creates a view from a given toast model.
    public init(toast: Toast) {
        image = toast.image
        text = toast.text
        style = toast.style
        action = toast.action
        focusesVoiceOver = toast.focusesVoiceOver
        presentationID = toast.presentationID
    }

    init(toast: Toast, onDismissRequested: @escaping () -> Void) {
        self.init(toast: toast)
        self.onDismissRequested = onDismissRequested
    }

    public var body: some View {
        // Any toast the user can tap away also leaves with the escape gesture. A toast with an action stays
        // while VoiceOver is running (`Toast.displayDuration`), so this closes it without taking the action.
        if onDismissRequested != nil {
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
            // Decorative: the text carries the message, and a resource image is otherwise read out by its
            // asset name ("infoToastIcon").
            .accessibilityHidden(true)

            Text(text)
                .style(style.textStyle)
                .foregroundStyle(style.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .accessibilityFocused($isMessageFocused)

            if let action {
                actionLink(action)
            }
        }
        .padding(style.insets)
        .background(style.backgroundColor, in: .rect(cornerRadius: style.cornerRadius))
        .shadow(style.shadow)
        .padding(appliesSidePadding ? style.padding : style.verticalPadding)
        .task(id: presentationID) { await focusVoiceOverIfNeeded() }
    }
}

private extension ToastStyle {
    /// `padding` with the sides zeroed, for a host that positions the toast horizontally itself.
    var verticalPadding: EdgeInsets {
        EdgeInsets(top: padding.top, leading: 0, bottom: padding.bottom, trailing: 0)
    }
}

private struct ToastAppliesSidePaddingKey: EnvironmentKey {
    static let defaultValue = true
}

extension EnvironmentValues {
    /// Whether a toast applies its style's side padding. A host that positions the stack itself turns it off.
    var toastAppliesSidePadding: Bool {
        get { self[ToastAppliesSidePaddingKey.self] }
        set { self[ToastAppliesSidePaddingKey.self] = newValue }
    }
}

// MARK: - Private

private extension ToastView {
    /// Moves VoiceOver onto the message, for a toast that takes focus rather than being announced. The message
    /// rather than the row, so an action stays its own stop after it. Straight away: until it lands, VoiceOver reads
    /// whatever the user's action changed under it.
    func focusVoiceOverIfNeeded() async {
        guard focusesVoiceOver, UIAccessibility.isVoiceOverRunning else { return }
        isMessageFocused = true
        await reclaimFocusIfTaken()
    }

    /// Takes VoiceOver's focus back, once, if VoiceOver moves it elsewhere within `focusGuardWindow`, e.g. its own
    /// pick as a sheet closes under the toast.
    func reclaimFocusIfTaken() async {
        let focusMoves = NotificationCenter.default
            .notifications(named: UIAccessibility.elementFocusedNotification)
            .map { _ in }
        let watch = Task { @MainActor in
            for await _ in focusMoves {
                guard let focused = UIAccessibility.focusedElement(using: .notificationVoiceOver) as? NSObject else { continue }
                if focused.accessibilityLabel == text { return }
                isMessageFocused = false
                await Task.yield()
                isMessageFocused = true
                return
            }
        }
        try? await Task.sleep(for: Self.focusGuardWindow)
        watch.cancel()
    }

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
                // The whole 44pt frame takes the tap and is what VoiceOver reports, not only the label's glyphs.
                .contentShape([.interaction, .accessibility], .rect)
                .padding(.vertical, min(0, (style.imageSize - Self.minimumHitHeight) / 2))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    ToastView(toast: .example)
}
