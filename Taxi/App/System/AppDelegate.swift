//
//  AppDelegate.swift
//  Showcase
//
//  Created by Anatoli Petrosyants on 27.02.23.
// 

import UIKit
import SwiftUI
import ComposableArchitecture
import FirebaseCore
import FirebaseFirestore
import GoogleMaps
import GooglePlaces
import Alamofire

final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    let store = Store(initialState: AppFeature.State()) {
        AppFeature()
    }
    
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {        
        FirebaseApp.configure()
        
        GMSServices.provideAPIKey(Configuration.current.mapKey)
        GMSServices.setMetalRendererEnabled(true)
        
        GMSPlacesClient.provideAPIKey(Configuration.current.mapKey)
        
  
        let origin = GoogleMapsDirections.Place.coordinate(
            coordinate: GoogleMapsDirections.LocationCoordinate2D(
                latitude: 40.18394662431355,
                longitude: 44.515071977924926
            )
        )
        
        let destination = GoogleMapsDirections.Place.coordinate(
            coordinate: GoogleMapsDirections.LocationCoordinate2D(
                latitude: 40.18853655504229,
                longitude: 44.515554775540835
            )
        )
      
        GoogleMapsDirections.direction(fromOrigin: origin, toDestination: destination)
        
//        GoogleMapsDirections.direction(fromOrigin: origin, toDestination: destination) { (response, error) -> Void in
//            // Check Status Code
//            guard response?.status == GoogleMapsDirections.StatusCode.ok else {
//                // Status Code is Not OK
//                Log.error(response?.errorMessage)
//                return
//            }
//
//            // Use .result or .geocodedWaypoints to access response details
//            // response will have same structure as what Google Maps Directions API returns
//            Log.info("it has \(response?.routes.count ?? 0) routes")
//        }

        self.store.send(.appDelegate(.didFinishLaunching))
        return true
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        self.store.send(.appDelegate(.didRegisterForRemoteNotifications(.success(deviceToken))))
    }

    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        self.store.send(.appDelegate(.didRegisterForRemoteNotifications(.failure(error))))
    }
}

import Alamofire

class GoogleMapsDirections {
    
    static let baseURLString = "https://maps.googleapis.com/maps/api/directions/json"
    static let key = Configuration.current.mapKey

    class func direction(fromOrigin origin: Place, 
                         toDestination destination: Place,
                         travelMode: TravelMode = .driving) {
        var requestParameters: [String : Any] = [
            "key" : GoogleMapsDirections.key,
            "origin" : origin.toString(),
            "destination" : destination.toString(),
            "mode" : travelMode.rawValue.lowercased()
        ]
        
        let response = AF.request(GoogleMapsDirections.baseURLString,
                                  method: .get,
                                  parameters: requestParameters)
            .responseJSON { response in
                Log.info("response \(response)")
            }
    }
}

extension GoogleMapsDirections {
    
    struct LocationCoordinate2D {
        public var latitude: Double
        public var longitude: Double
        
        public init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
    }
    
    enum TravelMode: String {
        case driving = "DRIVING"
        case walking = "WALKING"
        case bicycling = "BICYCLING"
        case transit = "TRANSIT"
    }
    
    enum Place {
        case stringDescription(address: String)
        case coordinate(coordinate: LocationCoordinate2D)
        case placeID(id: String)
        
        public func toString() -> String {
            switch self {
            case .stringDescription(let address):
                return address
            case .coordinate(let coordinate):
                return "\(coordinate.latitude),\(coordinate.longitude)"
            case .placeID(let id):
                return "place_id:\(id)"
            }
        }
    }
}
