//
//  RequestRideView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 09.11.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - RequestRideView

struct RequestRideView {
    let store: StoreOf<RequestRideFeature>
}

// MARK: - Views

extension RequestRideView: View {

    var body: some View {
        content
            .background(Color.black)
            .onAppear { self.store.send(.onViewAppear) }
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Text("RequestRide View")
            }
            .frame(maxWidth: .infinity, maxHeight: 120)
            .background(Color.black)
        }
    }
}
