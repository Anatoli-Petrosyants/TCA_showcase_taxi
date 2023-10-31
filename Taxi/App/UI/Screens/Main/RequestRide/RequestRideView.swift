//
//  RequestRideView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 31.10.23.
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
            .onLoad { self.store.send(.view(.onViewLoad)) }
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Text("Request Ride")
        }
    }
}


