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
    
    var startCoordinate: CLLocationCoordinate2D
    var endCoordinate: CLLocationCoordinate2D
    var polylinePoints: [String]?
    var overviewPolylinePoint: String?

    init(startCoordinate: CLLocationCoordinate2D,
         endCoordinate: CLLocationCoordinate2D,
         polylinePoints: [String]?,
         overviewPolylinePoint: String?) {
        self.startCoordinate = startCoordinate
        self.endCoordinate = endCoordinate
        self.polylinePoints = polylinePoints
        self.overviewPolylinePoint = overviewPolylinePoint
    }
    
    func makeUIView(context: Self.Context) -> UIViewType {
        let mapView = GMSMapView.map(withFrame: .zero, camera: .default)
        mapView.isBuildingsEnabled = true
        mapView.mapType = .normal
        mapView.settings.rotateGestures = false
        mapView.settings.tiltGestures = false
        
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
            let startMarker = startMarker(startCoordinate)
            startMarker.map = mapView
            
            let endMarker = endMarker(endCoordinate)
            endMarker.map = mapView
            
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
}

private extension RequestRideMapViewRepresentable {
    
    /// Create a square marker with an inner square view.
    ///
    /// - Parameters:
    ///   - coordinate: The coordinates for the marker's position.
    /// - Returns: A GMSMarker with a square icon.
    func startMarker(_ coordinate: CLLocationCoordinate2D) -> GMSMarker {
        let squareView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        squareView.backgroundColor = .white
        squareView.layer.cornerRadius = squareView.frame.size.width/2
        squareView.clipsToBounds = true
        
        let innerSquareView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        innerSquareView.center = CGPointMake(squareView.frame.size.width  / 2,
                                             squareView.frame.size.height / 2)
        innerSquareView.backgroundColor = .black
        squareView.addSubview(innerSquareView)
        
        let marker = GMSMarker()
        marker.position = coordinate
        marker.iconView = squareView
        return marker
    }
    
    /// Create an end marker with a square view.
    ///
    /// - Parameters:
    ///   - coordinate: The coordinates for the marker's position.
    /// - Returns: A GMSMarker with a square icon.
    func endMarker(_ coordinate: CLLocationCoordinate2D) -> GMSMarker {
        let squareView = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        squareView.backgroundColor = .white
        
        let innerSquareView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 5))
        innerSquareView.center = CGPointMake(squareView.frame.size.width  / 2,
                                             squareView.frame.size.height / 2)
        innerSquareView.backgroundColor = .black
        squareView.addSubview(innerSquareView)
        
        let marker = GMSMarker()
        marker.position = coordinate
        marker.iconView = squareView
        return marker
    }
}

