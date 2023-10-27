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
  
//        let origin = GoogleMapsDirections.Place.coordinate(
//            coordinate: GoogleMapsDirections.LocationCoordinate2D(
//                latitude: 40.18394662431355,
//                longitude: 44.515071977924926
//            )
//        )
//        
//        let destination = GoogleMapsDirections.Place.coordinate(
//            coordinate: GoogleMapsDirections.LocationCoordinate2D(
//                latitude: 40.19792272406243,
//                longitude: 44.51916420358389
//            )
//        )
//        
//        let destination = GoogleMapsDirections.Place.coordinate(
//            coordinate: GoogleMapsDirections.LocationCoordinate2D(
//                latitude: 40.19792272406243,
//                longitude: 44.51916420358389
//            )
//        )
        
        let origin = GoogleMapsDirections.Place.stringDescription(address: "Yerevan")
        let destination = GoogleMapsDirections.Place.stringDescription(address: "Dilijan")
      
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
    static let key = Configuration.current.directionKey

    class func direction(fromOrigin origin: Place, 
                         toDestination destination: Place,
                         travelMode: TravelMode = .driving) {
        let requestParameters: [String : Any] = [
            "key" : GoogleMapsDirections.key,
            "destination" : destination.toString(),
            "origin" : origin.toString(),
            "mode" : travelMode.rawValue.lowercased(),
            "region" : Configuration.current.country
        ]
        
//        let requestParameters: [String : Any] = [
//            "destination" : "Madrid",
//            "origin" : "Toledo",
//            "region" : "es",
//            "key" : GoogleMapsDirections.key
//        ]
        
        print("requestParameters \(requestParameters)")
        
//    https://maps.googleapis.com/maps/api/directions/json?destination=Yerevan&origin=Dilijan&region=am&mode=driving&key=AIzaSyC--Qx9Rx1bpKOsM-MxvAVEzq67eo6UiPc
        
        AF.request(GoogleMapsDirections.baseURLString,
                                  method: .get,
                                  parameters: requestParameters)
            .responseDecodable(of: GoogleMapsDirections.Response.self) { response in
                Log.info("direction response \(response)")
            }
    }
}

extension GoogleMapsDirections {
    
    enum StatusCode: String, Decodable {
        case ok = "OK"
        case notFound = "NOT_FOUND"
        case zeroResults = "ZERO_RESULTS"
        case maxWaypointsExceeded = "MAX_WAYPOINTS_EXCEEDED"
        case invalidRequest = "INVALID_REQUEST"
        case overQueryLimit = "OVER_QUERY_LIMIT"
        case requestDenied = "REQUEST_DENIED"
        case unknownError = "UNKNOWN_ERROR"
    }
    
    struct Route: Decodable {
        var copyrights: String?
        var summary: String?
        var legs: [Leg] = []

        struct Leg: Decodable {
            var startAddress: String?
            var endAddress: String?
            var startLocation: LocationCoordinate2D?
            var endLocation: LocationCoordinate2D?
            var steps: [Step] = []

            enum CodingKeys: String, CodingKey {
                case startAddress = "start_address"
                case endAddress = "end_address"
                case startLocation = "start_location"
                case endLocation = "end_location"
            }

            struct Step: Decodable {
                var travelMode: String?

                enum CodingKeys: String, CodingKey {
                    case travelMode = "travel_mode"
                }
//                
//                var distance: Distance?
//                var duration: Duration?
//                
//                struct Distance: Decodable {
//                    var value: Int?
//                    var text: String?
//                }
//                
//                struct Duration: Decodable {
//                    var value: Int?
//                    var text: String?
//                }
            }
        }
    }
    
    struct Response: Decodable {
        var status: StatusCode?
        var routes: [Route] = []
    }
}

//extension GoogleMapsDirections {
//    
//    enum StatusCode: String, Decodable {
//        case ok = "OK"
//        case notFound = "NOT_FOUND"
//        case zeroResults = "ZERO_RESULTS"
//        case maxWaypointsExceeded = "MAX_WAYPOINTS_EXCEEDED"
//        case invalidRequest = "INVALID_REQUEST"
//        case overQueryLimit = "OVER_QUERY_LIMIT"
//        case requestDenied = "REQUEST_DENIED"
//        case unknownError = "UNKNOWN_ERROR"
//    }
//    
//    enum GeocoderStatus: String, Decodable {
//        case ok = "OK"
//        case zeroResults = "ZERO_RESULTS"
//    }
//    
//    struct GeocodedWaypoint: Decodable {
////        var geocoderStatus: GeocoderStatus?
////        var placeID: String?
//        
////        enum CodingKeys: String, CodingKey {
////            case geocoderStatus = "geocoder_status"
////            case placeID = "place_id"
////        }
//    }
//    
//    struct Route: Decodable {
//        var copyrights: String?
//        var summary: String?
//    }
//    
////    struct Bounds: Decodable {
////        var northeast: LocationCoordinate2D?
////        var southwest: LocationCoordinate2D?
////    }
//    
//    struct Response: Decodable {
//        var status: StatusCode?
////        var errorMessage: String?
////        var geocodedWaypoints: [GeocodedWaypoint] = []
//        var routes: [Route] = []
//
////        enum CodingKeys: String, CodingKey {
////            case geocodedWaypoints = "geocoded_waypoints"
////            case errorMessage = "error_message"
////        }
//    }
//}

extension GoogleMapsDirections {
    
    struct LocationCoordinate2D: Decodable {
        var latitude: Double
        var longitude: Double
        
        init(latitude: Double, longitude: Double) {
            self.latitude = latitude
            self.longitude = longitude
        }
        
        enum CodingKeys: String, CodingKey {
            case latitude = "lat"
            case longitude = "lng"
        }
    }
    
    enum TravelMode: String, Decodable {
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
