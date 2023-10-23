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
                        .fill(Color.white)

                    Image(systemName: "square.fill")
                        .renderingMode(.template)
                        .foregroundColor(Color.primaryBlack)
                        .font(.system(size: 7))
                }
                .frame(width: 30, height: 30)

                Rectangle()
                    .frame(width: 2.0, height: 18)
                    .foregroundColor(Color.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
            .offset(y: moving ? -10 : 0.0)

            Ellipse()
                .frame(width: 6, height: 5)
                .foregroundColor(Color.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .opacity(moving ? 1.0 : 0.0)
        }
        .animation(.linear(duration: 0.1), value: moving)
    }
}
