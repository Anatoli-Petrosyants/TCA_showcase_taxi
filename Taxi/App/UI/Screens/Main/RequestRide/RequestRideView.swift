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
    
    @State private var opacity: Double = 0.0
}

// MARK: - Views

extension RequestRideView: View {
    
    var body: some View {
        content
            .onLoad { self.store.send(.view(.onViewLoad)) }
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack(alignment: .top) {
                RequestRideMapViewRepresentable(
                    startCoordinate: viewStore.startCoordinate,
                    endCoordinate: viewStore.endCoordinate,
                    polylinePoints: viewStore.polylinePoints,
                    overviewPolylinePoint: viewStore.overviewPolylinePoint
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


