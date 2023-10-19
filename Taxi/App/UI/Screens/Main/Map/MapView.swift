//
//  MapView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 10.10.23.
//

import SwiftUI
import ComposableArchitecture
import GoogleMaps

// MARK: - MapView

struct MapView {
    let store: StoreOf<MapFeature>
    
    @State private var moving: Bool = false
}

// MARK: - Views

extension MapView: View {
    
    var body: some View {
        content
            .onLoad { self.store.send(.view(.onViewLoad)) }
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }, send: { .view($0) }) { viewStore in
            ZStack(alignment: .bottomTrailing) {
                ZStack(alignment: .top) {
                    GoogleMapViewRepresentable(
                        userLocation: viewStore.userLocation,
                        mapViewIdleAtPosition: { position in
                            viewStore.send(.onMapViewIdleAtPosition(position))
                            moving = false
                        },
                        mapViewWillMove: { gesture in
                            moving = true
                        }
                    )

                    ChooseAddressPinView(moving: $moving)
                            .frame(width: 100, height: 100)
                            .padding(.top, (UIScreen.main.bounds.size.height - cameraTopPadding) / 2 - 92)
                }
                
                CurrentLocationButton(moving: $moving, didTap: {
                    viewStore.send(.onLocationButtonTap)
                })
                .offset(x: -10, y: -250)

                PickupSpotBottomSheetView(content: {
                    PickupSpotView(
                        store: self.store.scope(
                            state: \.pickupSpot,
                            action: MapFeature.Action.pickupSpot
                        )
                    )
                }, moving: $moving)
            }
            .ignoresSafeArea()
        }
    }
}
