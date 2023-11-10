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
            .background(Color.secondaryGray)
            .cornerRadius(16)
            // .clipShape(Capsule())
            .onAppear { self.store.send(.onViewAppear) }
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: [.init(.flexible(), spacing: 0, alignment: .leading)]) {
                    ForEach(viewStore.vehicles, id: \.self) { vehicle in
                        VStack(alignment: .center, spacing: 0) {
                            Image(vehicle.icon)
                                .renderingMode(.template)
                                .resizable()
                                .aspectRatio(contentMode: .fit)                                
                                .foregroundColor(Color.white05)
                                .frame(height: 40)
                                .padding(.top, 4)
                            
                            Text(vehicle.title)
                                .font(.footnote)
                                .foregroundColor(Color.white05)
                            
                            Text("11.22$")
                                .font(.footnote)
                                .foregroundColor(Color.white05)
                            
                            Spacer()
                        }
                        .padding(8)
                    }
                }
            }
        }
    }
}
