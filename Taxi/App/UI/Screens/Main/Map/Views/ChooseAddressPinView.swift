//
//  ChooseAddressPinView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 16.10.23.
//

import SwiftUI

struct ChooseAddressPinView: View {

    var body: some View {
        VStack(spacing: 2) {
            ChooseAddressPinContentView()
            
            Rectangle()
                .frame(width: 3, height: 22)
                .foregroundColor(Color.black)
        }
    }
}

struct ChooseAddressPinContentView: View {
    
    var body: some View {
        VStack {
            Image(systemName: "location.fill")
                .renderingMode(.template)
                .foregroundColor(Color.black)
                .font(.system(size: 18))
                .padding(10)
        }
        .background(Color.yellow)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white, lineWidth: 3)
        )
        .shadow(color: Color.black01, radius: 1)
    }
}
