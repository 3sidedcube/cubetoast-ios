//
//  ToastImage.swift
//  CubeToast
//
//  Created by Sam Davis on 02/06/2025.
//

import Foundation
import DeveloperToolsSupport

/// Image used to illustrate a toast message.
public enum ToastImage: Equatable {
    /// System symbol image.
    case sfSymbol(String)
    /// Image from an asset resource.
    case resource(ImageResource)
}
