//
//  ToastView.swift
//  CubeToast
//
//  Created by Sam Davis on 02/06/2025.
//

import SwiftUI
import CubeFoundationSwiftUI

struct ToastView: View {

    let image: ToastImage
    let text: String
    let toastStyle: ToastStyle

    var body: some View {
        HStack(spacing: 12) {
            Group {
                switch image {
                case .sfSymbol(let symbolName):
                    Image(systemName: symbolName)
                        .foregroundStyle(toastStyle.textColor)
                case .resource(let resource):
                    Image(resource)
                        .resizable()
                        .scaledToFill()
                }
            }
            .frame(size: toastStyle.imageSize)
            .background(toastStyle.accentColor, in: .circle)

            Text(text)
                .style(toastStyle.textStyle)
                .foregroundStyle(toastStyle.textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(toastStyle.backgroundColor, in: .rect(cornerRadius: toastStyle.cornerRadius))
        .shadow(toastStyle.shadow)
        .padding(toastStyle.padding)
    }

}

#Preview {
    ToastView(
        image: .sfSymbol("bubble.middle.bottom.fill"),
        text: "A lovely slice of buttered toast.",
        toastStyle: .default
    )
}
