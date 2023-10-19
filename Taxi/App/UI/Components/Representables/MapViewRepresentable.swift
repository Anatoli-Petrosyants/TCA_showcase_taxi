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

extension GMSCameraPosition {
    static let `default` = GMSCameraPosition.camera(withLatitude: 40.18397482, longitude: 44.51509883, zoom: 17.0)
}

struct GoogleMapViewRepresentable: UIViewRepresentable {
    
    typealias UIViewType = GMSMapView
    
//    var mapViewIdleAtPosition: (GMSCameraPosition) -> ()
//    var mapViewWillMove: (Bool) -> ()
//
//    init(mapViewIdleAtPosition: @escaping (GMSCameraPosition) -> Void,
//         mapViewWillMove: @escaping (Bool) -> Void) {
//        Log.info("GoogleMapViewRepresentable init")
//        self.mapViewIdleAtPosition = mapViewIdleAtPosition
//        self.mapViewWillMove = mapViewWillMove
//    }
    
    var userLocation: CLLocation?
    
    init(userLocation: CLLocation?) {
        Log.info("GoogleMapViewRepresentable init")
        self.userLocation = userLocation
    }
    
    func makeUIView(context: Self.Context) -> UIViewType {
        Log.info("GoogleMapViewRepresentable makeUIView")
        let mapView = GMSMapView.map(withFrame: .zero, camera: .default)
        return mapView
    }
    
    func updateUIView(_ mapView: UIViewType , context: Self.Context) {
        Log.info("GoogleMapViewRepresentable updateUIView")
    }
}

//struct GoogleMapViewRepresentable: UIViewRepresentable {
//    
//    static let topPadding: CGFloat = 200.0
//    
//    typealias UIViewType = GMSMapView
//    
//    var userLocation: CLLocation?
//    var mapViewIdleAtPosition: (GMSCameraPosition) -> ()
//    var mapViewWillMove: (Bool) -> ()
//
//    private let mapView = GMSMapView.map(withFrame: .zero, camera: .defaultCamera)
//    
//    init(userLocation: CLLocation?,
//         mapViewIdleAtPosition: @escaping (GMSCameraPosition) -> (),
//         mapViewWillMove: @escaping (Bool) -> ()) {
//        
//        Log.info("GoogleMapViewRepresentable init")
//        
//        self.userLocation = userLocation
//        self.mapViewIdleAtPosition = mapViewIdleAtPosition
//        self.mapViewWillMove = mapViewWillMove
//    }
//    
//    /// Creates a `UIView` instance to be presented.
//    func makeUIView(context: Self.Context) -> UIViewType {
//        Log.info("GoogleMapViewRepresentable makeUIView")
//        
//        mapView.isMyLocationEnabled = true
//        // mapView.isTrafficEnabled = true
//        mapView.isBuildingsEnabled = true
//        mapView.settings.rotateGestures = false
//        mapView.settings.tiltGestures = false
//        // mapView.settings.myLocationButton = true
//        mapView.delegate = context.coordinator
//        
//        let edgeInsets = UIEdgeInsets(top: 0,
//                                      left: 0,
//                                      bottom: GoogleMapViewRepresentable.topPadding,
//                                      right: 0)
//        mapView.padding = edgeInsets
//        
//        return mapView
//    }
//
//    /// Updates the presented `UIView` (and coordinator) to the latest configuration.
//    func updateUIView(_ mapView: UIViewType , context: Self.Context) {
//        Log.info("GoogleMapViewRepresentable updateUIView")
//        
////        if let location = userLocation {
////            mapView.animate(toLocation: location.coordinate)
////        }
//    }
//    
//    func makeCoordinator() -> GoogleMapCoordinator {
//        return GoogleMapCoordinator(self)
//    }
//}
//
//extension GoogleMapViewRepresentable {
//
//    class GoogleMapCoordinator: NSObject, GMSMapViewDelegate {
//
//        let parent : GoogleMapViewRepresentable
//
//        init(_ parent: GoogleMapViewRepresentable) {
//            self.parent = parent
//        }
//
//        // MARK: - MKMapViewDelegate
//        
//        func mapViewSnapshotReady(_ mapView: GMSMapView) {
////            Log.info("mapViewSnapshotReady")
//        }
//        
//        func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
//            // gesture If YES, this is occurring due to a user gesture.
//            // Log.info("willMove gesture \(gesture)")
//            // self.parent.userLocation = nil
//            self.parent.mapViewWillMove(gesture)
//        }
//        
//        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
////            Log.info("didChange position \(position)")
//        }
//        
//        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//            // Log.info("idleAt position \(position.target)")
//            self.parent.mapViewIdleAtPosition(position)
//        }
//
//        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
////            Log.info("didTapAt coordinate \(coordinate)")
//        }
//        
//        func mapView(_ mapView: GMSMapView, didTapMyLocation location: CLLocationCoordinate2D) {
////            Log.info("didTapMyLocation")
//        }
//    }
//}
//
//extension CLLocation {
//    
//    var toCamera: GMSCameraPosition {
//        return GMSCameraPosition.camera(withLatitude: self.coordinate.latitude,
//                                        longitude: self.coordinate.longitude,
//                                        zoom: 17.0)
//    }
//}
