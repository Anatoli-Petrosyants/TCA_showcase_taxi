//
//  CTAButtonStyle.swift
//  Showcase
//
//  Created by Anatoli Petrosyants on 31.03.23.
//

import SwiftUI

struct CTAButtonStyle: ButtonStyle {
    
    @Environment(\.isEnabled) private var isEnabled
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .font(.headlineBold)
            .frame(minWidth: 200, maxWidth: .infinity, minHeight: 52)
            .foregroundColor(Color.black)
            .background(isEnabled ? Color.white : .gray)
            .clipShape(Capsule())
    }
}

extension ButtonStyle where Self == CTAButtonStyle {
    static var cta: CTAButtonStyle { .init() }
}
