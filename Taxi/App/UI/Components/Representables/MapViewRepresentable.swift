//
//  MapViewRepresentable.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 11.10.23.
//

import SwiftUI
import GoogleMaps
import GoogleMapsUtils
import CoreLocation

struct GoogleMapViewRepresentable: UIViewRepresentable {
    
    static let topPadding: CGFloat = 200.0
    
    typealias UIViewType = GMSMapView
    
    @Binding var userLocation: CLLocation?
    
    var mapViewIdleAtPosition: (GMSCameraPosition) -> ()
    var mapViewWillMove: (Bool) -> ()
         
    private let mapView : GMSMapView

    init(userLocation: Binding<CLLocation?>,
         mapViewIdleAtPosition: @escaping (GMSCameraPosition) -> (),
         mapViewWillMove: @escaping (Bool) -> ()) {
        mapView = GMSMapView.map(withFrame: CGRect.zero, camera: .defaultCamera)
        mapView.isMyLocationEnabled = true
        // mapView.isTrafficEnabled = true
        mapView.isBuildingsEnabled = true
        mapView.settings.rotateGestures = false
        mapView.settings.tiltGestures = false
        // mapView.settings.myLocationButton = true
        
        let edgeInsets = UIEdgeInsets(top: 0,
                                      left: 0,
                                      bottom: GoogleMapViewRepresentable.topPadding,
                                      right: 0)
        mapView.padding = edgeInsets
        
        self._userLocation = userLocation
        self.mapViewIdleAtPosition = mapViewIdleAtPosition
        self.mapViewWillMove = mapViewWillMove
    }
    
    /// Creates a `UIView` instance to be presented.
    func makeUIView(context: Self.Context) -> UIViewType {
        mapView.delegate = context.coordinator
        return mapView
    }

    /// Updates the presented `UIView` (and coordinator) to the latest configuration.
    func updateUIView(_ mapView: UIViewType , context: Self.Context) {
        if let location = userLocation {
            mapView.animate(toLocation: location.coordinate)
        }
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
            // Log.info("willMove gesture \(gesture)")
            // self.parent.userLocation = nil
            self.parent.mapViewWillMove(gesture)
        }
        
        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
//            Log.info("didChange position \(position)")
        }
        
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            // Log.info("idleAt position \(position.target)")
            self.parent.mapViewIdleAtPosition(position)
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

extension CLLocation {
    
    var toCamera: GMSCameraPosition {
        return GMSCameraPosition.camera(withLatitude: self.coordinate.latitude,
                                        longitude: self.coordinate.longitude,
                                        zoom: 17.0)
    }
}
