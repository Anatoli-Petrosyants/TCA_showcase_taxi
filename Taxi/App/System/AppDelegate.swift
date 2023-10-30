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

//    https://maps.googleapis.com/maps/api/directions/json?destination=Yerevan&origin=Dilijan&region=am&mode=driving&key=AIzaSyC--Qx9Rx1bpKOsM-MxvAVEzq67eo6UiPc
        
        AF.request(GoogleMapsDirections.baseURLString,
                                  method: .get,
                                  parameters: requestParameters)
            .responseDecodable(of: GoogleMapsDirections.Response.self) { response in
                switch response.result {
                    case .success(let data):
                        dump(data)
                    case .failure(let error):
                        print(error)
                }
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
        var bounds: Bounds?

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
                case steps
            }
            
            struct Step: Decodable {
                var htmlInstructions: String?
                var distance: Distance?
                var duration: Duration?
                var startLocation: LocationCoordinate2D?
                var endLocation: LocationCoordinate2D?
                var travelMode: TravelMode?

                enum CodingKeys: String, CodingKey {
                    case htmlInstructions = "html_instructions"
                    case distance, duration
                    case travelMode = "travel_mode"
                    case startLocation = "start_location"
                    case endLocation = "end_location"
                }
                
                struct Distance: Decodable {
                    var value: Int?
                    var text: String?
                }

                struct Duration: Decodable {
                    var value: Int?
                    var text: String?
                }
            }
        }

        struct Bounds: Decodable {
            var northeast: LocationCoordinate2D?
            var southwest: LocationCoordinate2D?
        }
    }
    
    struct GeocodedWaypoint: Decodable {
        enum GeocoderStatus: String, Decodable {
            case ok = "OK"
            case zeroResults = "ZERO_RESULTS"
        }
        
        var placeID: String?
        var geocoderStatus: GeocoderStatus?
        
        enum CodingKeys: String, CodingKey {
            case placeID = "place_id"
            case geocoderStatus = "geocoder_status"
        }
    }
    
    struct Response: Decodable {
        var status: StatusCode?
        var errorMessage: String?
        var geocodedWaypoints: [GeocodedWaypoint] = []
        var routes: [Route] = []
        
        enum CodingKeys: String, CodingKey {
            case status, routes
            case errorMessage = "error_message"
            case geocodedWaypoints = "geocoded_waypoints"
        }
    }
}

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

