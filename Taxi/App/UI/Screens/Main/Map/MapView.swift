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
    
    @State private var moving: Bool = true
    
    @State private var isPresented = true
    
    struct ViewState: Equatable {
        @BindingViewState var userLocation: CLLocation?
    }
}

// MARK: - Views

extension MapView: View {
    
    var body: some View {
        content
            .onLoad { self.store.send(.view(.onViewLoad)) }
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: \.view, send: { .view($0) }) { viewStore in
            ZStack(alignment: .bottomTrailing) {
                ZStack(alignment: .top) {
                    GoogleMapViewRepresentable(
                        userLocation: viewStore.$userLocation,
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
                                .padding(.top, UIScreen.main.bounds.size.height / 2 - 92)
                }
                
//                VStack(spacing: 10) {
//                    CurrentLocationButton(moving: $moving, didTap: {
//                        viewStore.send(.onLocationButtonTap)
//                    })
//                }
                
//                CurrentLocationButton(moving: $moving, didTap: {
//                    viewStore.send(.onLocationButtonTap)
//                })
//                .offset(x: -20, y: -20)
                
                CurrentLocationButton(moving: $moving, didTap: {
                    isPresented = true
                })
                .offset(x: -20, y: -20)
            }
            .ignoresSafeArea()
        }
    }
}

// MARK: BindingViewStore

extension BindingViewStore<MapFeature.State> {
    var view: MapView.ViewState {
        MapView.ViewState(userLocation: self.$userLocation)
    }
}

