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
    
//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 40.183974823578815,
//                                       longitude: 44.51509883139478),
//        span: MKCoordinateSpan(latitudeDelta: 0.001,
//                               longitudeDelta: 0.001))
}

// MARK: - Views

extension MapView: View {
    
    var body: some View {
        content
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                GoogleMapViewRepresentable()
                
                Image(systemName: "mappin")
                    .font(.system(size: 40))
                    .position(x: UIScreen.main.bounds.size.width / 2, y: 200)
            }
        }
    }
}


// https://github.com/googlemaps-samples/maps-sdk-for-ios-samples/issues/58
