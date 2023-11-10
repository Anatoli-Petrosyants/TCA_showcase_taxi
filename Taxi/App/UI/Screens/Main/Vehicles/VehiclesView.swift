//
//  VehiclesView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 09.11.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - VehiclesView

struct VehiclesView {
    let store: StoreOf<VehiclesFeature>
}

// MARK: - Views

extension VehiclesView: View {
    
    var body: some View {
        content
            .onAppear { self.store.send(.onViewAppear) }
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView(showsIndicators: false) {
                LazyHGrid(rows: [.init(.flexible(), spacing: 8, alignment: .leading)]) {
                    ForEach(viewStore.vehicles, id: \.self) { vehicle in
                        // Text(vehicle.title)
                    }
                }
//                .padding([.leading, .trailing], 8)
//                .aspectRatio(1.0, contentMode: .fit)
            }
            .padding()
            .background(Color.red)
        }
    }
}
