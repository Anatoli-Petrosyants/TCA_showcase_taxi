//
//  MapView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 10.10.23.
//

import SwiftUI
import ComposableArchitecture
import MapKit
import CoreLocationUI
import SDWebImageSwiftUI

// MARK: - MapView

struct MapView {
    let store: StoreOf<MapFeature>
    
    @State private var moving: Bool = true
}

// MARK: - Views

extension MapView: View {
    
    var body: some View {
        content
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                GoogleMapViewRepresentable(
                    mapViewIdleAtPosition: { position in
                        Log.debug("mapViewIdleAtPosition \(position)")
                        
                        withAnimation {
                            moving = false
                        }
                    },
                    mapViewWillMove: { gesture in
                        Log.debug("mapViewWillMove \(gesture)")
                        
                        withAnimation {
                            moving = true
                        }
                    }
                )
                
                ChooseAddressPinView()
                    .position(x: UIScreen.main.bounds.size.width / 2,
                              y: moving ? 285 : 300)
            }
        }
    }
}
