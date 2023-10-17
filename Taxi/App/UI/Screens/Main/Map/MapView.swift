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
            ZStack(alignment: .top) {
                GoogleMapViewRepresentable(
                    mapViewIdleAtPosition: { position in
                        moving = false
                    },
                    mapViewWillMove: { gesture in
                        moving = true
                    }
                )
                
                // #dev To align the text at the bottom of the ZStack,
                // you need to use the .frame and .alignment modifiers. A.P.
                ZStack {
                    ChooseAddressPinView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .offset(y: moving ? -10 : 0.0)
                    
                    Ellipse()
                        .frame(width: 7, height: 6)
                        .foregroundColor(Color.black)
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                        .opacity(moving ? 1.0 : 0.0)
                }
                .animation(.linear(duration: 0.1), value: moving)
                .frame(width: 100, height: 150)
                .padding(.top, 150)
            }
            .ignoresSafeArea()
            
            
////                CurrentLocationButton(didTap: {
////                    Log.debug("CurrentLocationButton didTap")
////                })
////                .opacity(moving ? 0 : 1.0)
////                .offset(x: -20, y: -20)
//            }
        }
    }
}
