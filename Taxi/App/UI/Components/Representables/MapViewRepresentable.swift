//
//  MapViewRepresentable.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 11.10.23.
//

import SwiftUI
import MapKit

struct MapViewRepresentable: UIViewRepresentable {
    
    let mapView = MKMapView()

    func makeUIView(context: Context) -> some UIView {
        mapView.delegate = context.coordinator
        mapView.isRotateEnabled = false
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.isZoomEnabled = true

        let configuration = MKStandardMapConfiguration(elevationStyle: .realistic, emphasisStyle: .default)
        configuration.showsTraffic = true
        mapView.preferredConfiguration = configuration
        
        return mapView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        Log.info("updateUIView")
        // Log.info("DEBUG: map view State -> \(mapState)")
    }
    
    func makeCoordinator() -> MapCoordinator {
        return MapCoordinator(parent: self)
    }
}

extension MapViewRepresentable {
    
    class MapCoordinator: NSObject, MKMapViewDelegate {
        
        // MARK: - Properties
        
        let parent : MapViewRepresentable
        
        // MARK: - Lifecycle
        init(parent: MapViewRepresentable) {
            self.parent = parent
            super.init()
        }
        
        // MARK: - MKMapViewDelegate
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            return nil
        }
        
//        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
//            let polyLine = MKPolylineRenderer(overlay: overlay)
//            polyLine.strokeColor = UIColor(Color.theme.goldBackgroundColor.opacity(0.92))
//            polyLine.lineWidth = 7
//            return polyLine
//        }
        
        // MARK: - Helpers
    }
}
