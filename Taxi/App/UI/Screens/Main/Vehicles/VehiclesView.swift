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
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [.init(.flexible(), spacing: 0, alignment: .leading)]) {
                    ForEach(viewStore.vehicles, id: \.self) { vehicle in
                        Text(vehicle.title)
                            .frame(width: 100, height: 40, alignment: .center)
                            .background(Color.green)
                            .padding(.leading, 8)
                    }
                }
            }
            .padding()
            .background(Color.black)
        }
    }
}
