//
//  AppTextFieldStyle.swift
//  Showcase
//
//  Created by Anatoli Petrosyants on 21.06.23.
//

import SwiftUI

struct AppTextFieldStyle: TextFieldStyle {
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding(.vertical, 8)
            .foregroundColor(Color.white)
        
            Rectangle()
            .frame(height: 0.5)
                .foregroundColor(Color.white05)
    }
}

extension TextFieldStyle where Self == AppTextFieldStyle {
    static var main: AppTextFieldStyle { .init() }
}
