//
//  RequestMapView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 31.10.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - RequestRideView

struct RequestMapView {
    let store: StoreOf<RequestMapFeature>
    
    @State private var opacity: Double = 0.0
}

// MARK: - Views

extension RequestMapView: View {
    
    var body: some View {
        content
            .onLoad { self.store.send(.view(.onViewLoad)) }
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack(alignment: .bottomTrailing) {
                ZStack(alignment: .top) {
                    RequestRideMapViewRepresentable(
                        startCoordinate: viewStore.startCoordinate,
                        endCoordinate: viewStore.endCoordinate,
                        polylinePoints: viewStore.polylinePoints,
                        overviewPolylinePoint: viewStore.overviewPolylinePoint
                    )
                }
                
                RequestRideView(
                    store: self.store.scope(
                        state: \.requestRide,
                        action: RequestMapFeature.Action.requestRide
                    )
                )
            }
            .ignoresSafeArea()
        }
    }
}

// Create an immediate animation.
extension View {
    func animate(using animation: Animation = .easeInOut(duration: 1), _ action: @escaping () -> Void) -> some View {
        onAppear {
            withAnimation(animation) {
                action()
            }
        }
    }
}


