//
//  MapViewRepresentable.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 11.10.23.
//

import SwiftUI
import MapKit

//struct MapViewRepresentable: UIViewRepresentable {
//
//    func makeUIView(context: Context) -> some UIView {
//        Log.info("MapViewRepresentable makeUIView")
//
//        let mapView = MKMapView(frame: .zero)
//        mapView.delegate = context.coordinator
//        mapView.isRotateEnabled = false
//        mapView.showsUserLocation = true
//        mapView.userTrackingMode = .follow
//        mapView.isZoomEnabled = true
//        // mapView.cameraZoomRange
//        mapView.mapType = .hybridFlyover
//
//        let configuration = MKStandardMapConfiguration(elevationStyle: .realistic, emphasisStyle: .default)
//        configuration.showsTraffic = true
//        mapView.preferredConfiguration = configuration
//
//        return mapView
//    }
//
//    func updateUIView(_ uiView: UIViewType, context: Context) {
//        Log.info("MapViewRepresentable updateUIView")
//    }
//
//    func makeCoordinator() -> MapCoordinator {
//        return MapCoordinator(self)
//    }
//}
//
//extension MapViewRepresentable {
//
//    class MapCoordinator: NSObject, MKMapViewDelegate {
//
//        let mapView : MapViewRepresentable
//        var userLocationCoordinate : CLLocationCoordinate2D?
//
//        init(_ mapView: MapViewRepresentable) {
//            self.mapView = mapView
//        }
//
//        // MARK: - MKMapViewDelegate
//
////        func mapViewWillStartLoadingMap(_ mapView: MKMapView) {
////            Log.info("mapViewWill StartLoadingMap")
////        }
////
////        func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
////            Log.info("mapViewDid FinishLoadingMap")
////        }
////
////        func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
////            Log.info("mapViewDid FailLoadingMap")
////        }
//
//        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
//            Log.info("mapView didUpdate userLocation \(userLocation)")
//        }
//    }
//}



//extension MapViewRepresentable {
//
//    class MapCoordinator: NSObject, MKMapViewDelegate {
//
//        // MARK: - Properties
//
//        let parent : MapViewRepresentable
//        var currentUserRegion : MKCoordinateRegion?
//
//        // MARK: - Lifecycle
//        init(parent: MapViewRepresentable) {
//            self.parent = parent
//            super.init()
//        }
//
//        // MARK: - MKMapViewDelegate
//        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
////            let userRegion = MKCoordinateRegion(
////                center: CLLocationCoordinate2D(latitude: userLocation.coordinate.latitude,
////                                               longitude: userLocation.coordinate.longitude),
////                span: MKCoordinateSpan(latitudeDelta: 0.07,
////                                       longitudeDelta: 0.07))
////
////            Log.debug("userRegion \(userRegion)")
////
////            self.currentUserRegion = userRegion
////
////            parent.mapView.setRegion(userRegion, animated: true)
//        }
//
//        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//            return nil
//        }
//
////        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
////            let polyLine = MKPolylineRenderer(overlay: overlay)
////            polyLine.strokeColor = UIColor(Color.theme.goldBackgroundColor.opacity(0.92))
////            polyLine.lineWidth = 7
////            return polyLine
////        }
//
//        // MARK: - Helpers
//    }
//}
