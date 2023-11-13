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
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(alignment: .leading) {
                VehiclesView(
                    store: self.store.scope(
                        state: \.vehicles,
                        action: RequestRideFeature.Action.vehicles
                    )
                )
                .frame(height: 80)
                .padding(8)
                
                Button("Verify", action: {
                    viewStore.send(.view(.onVerifyTap))
                })
                .buttonStyle(.cta)
                .padding(8)
                
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 220)
            .background(Color.black)
        }
    }
}
