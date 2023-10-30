//
//  GoogleDirectionsClient.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 30.10.23.
//

import Foundation
import Dependencies

struct GoogleDirectionsClient {
    var directions: @Sendable (GoogleDirectionsClient.Request) async throws -> GoogleDirectionsClient.Response
}

// common
extension GoogleDirectionsClient {

    enum TravelMode: String, Decodable {
        case driving = "DRIVING"
        case walking = "WALKING"
        case bicycling = "BICYCLING"
        case transit = "TRANSIT"
    }
    
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
}

// request
extension GoogleDirectionsClient {
    
    struct Request {
        let origin: Place
        let destination: Place
        
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
}

// response
extension GoogleDirectionsClient {
    
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

//let requestParameters: [String : Any] = [
//    "key" : GoogleMapsDirections.key,
//    "destination" : destination.toString(),
//    "origin" : origin.toString(),
//    "mode" : travelMode.rawValue.lowercased(),
//    "region" : Configuration.current.country
//]

extension DependencyValues {
    var googleDirectionsClient: GoogleDirectionsClient {
        get { self[GoogleDirectionsClient.self] }
        set { self[GoogleDirectionsClient.self] = newValue }
    }
}

extension GoogleDirectionsClient: DependencyKey {
    static let liveValue: Self = {
        
        return Self(
            directions: { data in
                return try await withCheckedThrowingContinuation { continuation in
                    
                }
            }
        )
    }()
}
