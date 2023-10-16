//
//  CurrentLocationButton.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 16.10.23.
//

import SwiftUI

struct CurrentLocationButton: View {
    
    var didTap: () -> ()
    
    var body: some View {
        Button {
            didTap()
        } label: {
            Image(systemName: "location.fill")
                .renderingMode(.template)
                .foregroundColor(Color.black)
                .font(.system(size: 20))
                .padding(12)
                .background(Color.yellow)
                .clipShape(Circle())
                .shadow(color: Color.black01, radius: 4)
        }
    }
}
