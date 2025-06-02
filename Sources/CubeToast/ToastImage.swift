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
    case sfSymbol(String)
    case resource(ImageResource)
}
