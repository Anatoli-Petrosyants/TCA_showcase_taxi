//
//  MapViewRepresentable.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 11.10.23.
//

import SwiftUI
import GoogleMaps
import CoreLocation
import GoogleMapsUtils

struct GoogleMapViewRepresentable: UIViewRepresentable {
     
    typealias UIViewType = GMSMapView
    private let mapView : GMSMapView

    init() {
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: .defaultCamera)
        mapView.isMyLocationEnabled = true
        mapView.isTrafficEnabled = true
        mapView.isBuildingsEnabled = true
        mapView.settings.rotateGestures = false
        mapView.settings.tiltGestures = false
        mapView.settings.myLocationButton = true
    }
    
    /// Creates a `UIView` instance to be presented.
    func makeUIView(context: Self.Context) -> UIViewType {
        Log.info("GoogleMapViewRepresentable makeUIView")
        mapView.delegate = context.coordinator
        return mapView
    }

    /// Updates the presented `UIView` (and coordinator) to the latest
    /// configuration.
    func updateUIView(_ mapView: UIViewType , context: Self.Context) {
        Log.info("GoogleMapViewRepresentable updateUIView")
    }
       
    func update(cameraPosition: GMSCameraPosition) -> some View {
        mapView.animate(to: cameraPosition)
        return self
    }
    
    func update(zoom level: Float) -> some View {
        mapView.animate(toZoom: level)
        return self
    }
    
    func makeCoordinator() -> GoogleMapCoordinator {
        return GoogleMapCoordinator(self)
    }
}

extension GoogleMapViewRepresentable {

    class GoogleMapCoordinator: NSObject, GMSMapViewDelegate {

        let parent : GoogleMapViewRepresentable

        init(_ parent: GoogleMapViewRepresentable) {
            self.parent = parent
        }

        // MARK: - MKMapViewDelegate
        
        func mapViewSnapshotReady(_ mapView: GMSMapView) {
//            Log.info("mapViewSnapshotReady")
        }
        
        func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
            // gesture If YES, this is occurring due to a user gesture.
//            Log.info("willMove gesture \(gesture)")
        }
        
        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//            Log.info("didChange position \(position)")
        }
        
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            Log.info("idleAt position \(position.target)")
            
            let projection = mapView.projection
            let centerPoint = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: 200)
            Log.info("idleAt projection \(projection.coordinate(for: centerPoint))")
            
//            let projection = mapView.projection.visibleRegion()
//            Log.info("idleAt projection \(projection)")
        }

        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
//            Log.info("didTapAt coordinate \(coordinate)")
        }
        
        func mapView(_ mapView: GMSMapView, didTapMyLocation location: CLLocationCoordinate2D) {
//            Log.info("didTapMyLocation")
        }
    }
}

extension GMSCameraPosition {

    static let defaultCamera = GMSCameraPosition.camera(withLatitude: 40.183974823578815,
                                                        longitude: 44.51509883139478,
                                                        zoom: 17.0)
}
