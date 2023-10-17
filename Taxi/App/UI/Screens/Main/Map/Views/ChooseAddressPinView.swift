//
//  ChooseAddressPinView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 16.10.23.
//

import SwiftUI

struct ChooseAddressPinView: View {

    @Binding var moving: Bool

    var body: some View {
        ZStack {
            // #dev To align the text at the bottom of the ZStack,
            // you need to use the .frame and .alignment modifiers. A.P.
            VStack(spacing: 0) {
                ZStack {
                    Circle()
                        .fill(Color.black)

                    Image(systemName: "location.fill")
                        .renderingMode(.template)
                        .foregroundColor(Color.yellow)
                        .font(.system(size: 14))
                }
                .shadow(color: Color.black.opacity(0.1), radius: 1)
                .frame(width: 36, height: 36)

                Rectangle()
                    .frame(width: 2.5, height: 22)
                    .foregroundColor(Color.black)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .offset(y: moving ? -10 : 0.0)

            Ellipse()
                .frame(width: 7, height: 6)
                .foregroundColor(Color.black)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .opacity(moving ? 1.0 : 0.0)
        }
        .animation(.linear(duration: 0.1), value: moving)
    }
}
