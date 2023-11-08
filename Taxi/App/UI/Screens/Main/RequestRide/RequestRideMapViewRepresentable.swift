//
//  RequestRideMapViewRepresentable.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 08.11.23.
//

import SwiftUI
import GoogleMaps

struct RequestRideMapViewRepresentable: UIViewRepresentable {
    
    typealias UIViewType = GMSMapView
    
    var polylinePoints: [String]?
    var overviewPolylinePoint: String?

    init(polylinePoints: [String]?, overviewPolylinePoint: String?) {
        self.polylinePoints = polylinePoints
        self.overviewPolylinePoint = overviewPolylinePoint
    }
    
    func makeUIView(context: Self.Context) -> UIViewType {
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
        if let polylinePoints = polylinePoints, polylinePoints.count > 0 {
            for point in polylinePoints {
                let path = GMSPath(fromEncodedPath: point)
                let polyline = GMSPolyline(path: path)
                polyline.strokeColor = .white
                polyline.strokeWidth = 3.0
                polyline.map = mapView
            }
            
            if let overviewPolylinePoint = overviewPolylinePoint {
                if let overviewPolylinePath = GMSPath(fromEncodedPath: overviewPolylinePoint) {
                    let bounds = GMSCoordinateBounds(path: overviewPolylinePath)
                    let insets = UIEdgeInsets(top: 20, left: 40, bottom: 200, right: 40)
                    let camera = GMSCameraUpdate.fit(bounds, with: insets)
                    mapView.animate(with: camera)
                }
            }
        }
    }
    
    func makeCoordinator() -> GoogleMapCoordinator {
        return GoogleMapCoordinator(self)
    }
}

extension RequestRideMapViewRepresentable {

    class GoogleMapCoordinator: NSObject, GMSMapViewDelegate {

        var parent: RequestRideMapViewRepresentable

        init(_ parent: RequestRideMapViewRepresentable) {
            self.parent = parent
        }

        // MARK: - MKMapViewDelegate
        
        func mapViewSnapshotReady(_ mapView: GMSMapView) {
            // Log.info("mapViewSnapshotReady")
        }
        
        func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
            // Log.info("willMove gesture \(gesture)")
        }
        
        func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
            // Log.info("didChange position \(position)")
        }
        
        func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
            // Log.info("idleAt position \(position.target)")
        }

        func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
            // Log.info("didTapAt coordinate \(coordinate)")
        }
    }
}
