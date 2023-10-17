//
//  ChooseAddressPinView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 16.10.23.
//

import SwiftUI

struct ChooseAddressPinView: View {    
    var body: some View {
        VStack(spacing: 0) {
            ChooseAddressPinContentView()
            
            Rectangle()
                .frame(width: 2.5, height: 22)
                .foregroundColor(Color.black)
        }
    }
}

struct ChooseAddressPinContentView: View {
    
    var body: some View {
        
        ZStack {
            Circle()
                .fill(Color.black)
            
            Image(systemName: "location.fill")
                .renderingMode(.template)
                .foregroundColor(Color.yellow)
                .font(.system(size: 14))
        }
        .shadow(color: Color.black01, radius: 1)
        .frame(width: 36, height: 36)
    }
}
