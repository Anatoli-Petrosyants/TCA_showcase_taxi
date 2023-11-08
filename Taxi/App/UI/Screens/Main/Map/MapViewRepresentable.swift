//
//  MapViewRepresentable.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 11.10.23.
//

import SwiftUI
import GoogleMaps
import CoreLocation

extension GMSCameraPosition {
    static let `default` = GMSCameraPosition.camera(withLatitude: 40.18397482, longitude: 44.51509883, zoom: 18.0)
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
    
    static func != (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return lhs.latitude != rhs.latitude && lhs.longitude != rhs.longitude
    }
}

let cameraTopPadding: CGFloat = 110.0

struct GoogleMapViewRepresentable: UIViewRepresentable {
    
    typealias UIViewType = GMSMapView
    
    var userLocation: CLLocation?
    var mapViewIdleAtPosition: (GMSCameraPosition) -> ()
    var mapViewWillMove: (Bool) -> ()

    init(userLocation: CLLocation?,
         mapViewIdleAtPosition: @escaping (GMSCameraPosition) -> Void,
         mapViewWillMove: @escaping (Bool) -> Void) {
        // Log.info("GoogleMapViewRepresentable init userLocation \(String(describing: userLocation))")
        
        self.userLocation = userLocation
        self.mapViewIdleAtPosition = mapViewIdleAtPosition
        self.mapViewWillMove = mapViewWillMove
    }
    
    func makeUIView(context: Self.Context) -> UIViewType {
        // Log.info("GoogleMapViewRepresentable makeUIView \(String(describing: userLocation))")
        
        let mapView = GMSMapView.map(withFrame: .zero, camera: .default)
        mapView.isBuildingsEnabled = true
        mapView.mapType = .normal
        mapView.settings.rotateGestures = false
        mapView.settings.tiltGestures = false
        mapView.delegate = context.coordinator
        
        do {
          if let styleURL = Bundle.main.url(forResource: "map_style", withExtension: "json") {
              mapView.mapStyle = try GMSMapStyle(contentsOfFileURL: styleURL)
          } else {
              Log.error("Unable to find style.json")
          }
        } catch {
            Log.error("One or more of the map styles failed to load. \(error)")
        }
        
        return mapView
    }
    
    func updateUIView(_ mapView: UIViewType , context: Self.Context) {
        if let location = userLocation {
            mapView.animate(toLocation: location.coordinate)
            mapView.isMyLocationEnabled = true
        }
    }
    
    func makeCoordinator() -> GoogleMapCoordinator {
        return GoogleMapCoordinator(self)
    }
}

extension GoogleMapViewRepresentable {

    class GoogleMapCoordinator: NSObject, GMSMapViewDelegate {

        var parent: GoogleMapViewRepresentable

        init(_ parent: GoogleMapViewRepresentable) {
            self.parent = parent
        }

        // MARK: - MKMapViewDelegate
        
        func mapViewSnapshotReady(_ mapView: GMSMapView) {
            // Log.info("mapViewSnapshotReady")
        }
        
        func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
            // Log.info("willMove gesture \(gesture)")
            self.parent.mapViewWillMove(gesture)
        }
        
        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            // Log.info("didChange position \(position)")
        }
        
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            // Log.info("idleAt position \(position.target)")
            self.parent.mapViewIdleAtPosition(position)
        }

        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            // Log.info("didTapAt coordinate \(coordinate)")
        }
        
        func mapView(_ mapView: GMSMapView, didTapMyLocation location: CLLocationCoordinate2D) {
            // Log.info("didTapMyLocation")
        }
    }
}
