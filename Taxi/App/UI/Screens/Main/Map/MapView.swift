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
                            moving = false
                        },
                        mapViewWillMove: { gesture in
                            moving = true
                        }
                    )
                                        
                    ChooseAddressPinView(moving: $moving)
                                .frame(width: 100, height: 150)
                                .padding(.top, 150)
                }
                
//                CurrentLocationButton(didTap: {                    
//                    viewStore.send(.onLocationButtonTap)
//                })
//                .opacity(moving ? 0 : 1.0)
//                .animation(.linear(duration: 0.1), value: moving)
//                .offset(x: -20, y: -20)
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
