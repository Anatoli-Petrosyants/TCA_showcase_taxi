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
}

// MARK: - Views

extension MapView: View {
    
    var body: some View {
        content
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            GeometryReader { geometry in
                ZStack {
                    Text("Map")                    
//                    Map(coordinateRegion: viewStore.binding(
//                                        get: \.mapRegion,
//                                        send: MapFeature.Action.mapRegionChanged(_:)
//                                    ),
//                        annotationItems: viewStore.annotations) { annotation in
//                            MapAnnotation(coordinate: annotation.coordinate) {
//                                WebImage(url: URL(string: annotation.path))
//                                    .resizable()
//                                    .placeholder(Image(systemName: "photo"))
//                                    .indicator(.activity)
//                                    .transition(.fade(duration: 0.5))
//                                    .scaledToFit()
//                                    .clipped()
//                                    .overlay(
//                                        Circle()
//                                            .stroke(Color.black, lineWidth: 4)
//                                    )
//                                    .frame(width: 30, height: 30)
//                            }
//                        }
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
        }
    }
}
