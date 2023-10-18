//
//  PickupSpotView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 18.10.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - PickupSpotView

struct PickupSpotView {
    let store: StoreOf<PickupSpotFeature>
}

// MARK: - Views

extension PickupSpotView: View {
    
    var body: some View {
        content.onAppear { self.store.send(.onViewAppear) }
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Text("Pickup SpotView")
        }
    }
}
