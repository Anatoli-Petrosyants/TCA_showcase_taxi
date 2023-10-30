//
//  GoogleDirectionsClient.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 30.10.23.
//

import Foundation
import Dependencies

/// A client for interacting with the Google Directions API.
struct GoogleDirectionsClient {
    var directions: @Sendable (GoogleDirectionsClient.Request) async throws -> GoogleDirectionsClient.Response
}

// Common data shared between requests and responses.
extension GoogleDirectionsClient {

    /// Travel modes available for directions.
    enum TravelMode: String, Decodable, Equatable {
        case driving = "DRIVING"
        case walking = "WALKING"
        case bicycling = "BICYCLING"
        case transit = "TRANSIT"
    }
    
    /// Represents a geographic coordinate with latitude and longitude.
    struct LocationCoordinate2D: Decodable, Equatable {
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

// Request structure for obtaining directions.
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

// Response structures from the Google Directions API.
extension GoogleDirectionsClient {
    
    /// Status codes for Google Directions API responses.
    enum StatusCode: String, Decodable, Equatable {
        case ok = "OK"
        case notFound = "NOT_FOUND"
        case zeroResults = "ZERO_RESULTS"
        case maxWaypointsExceeded = "MAX_WAYPOINTS_EXCEEDED"
        case invalidRequest = "INVALID_REQUEST"
        case overQueryLimit = "OVER_QUERY_LIMIT"
        case requestDenied = "REQUEST_DENIED"
        case unknownError = "UNKNOWN_ERROR"
    }
    
    /// Represents a route from the origin to the destination.
    struct Route: Decodable, Equatable {
        var copyrights: String?
        var summary: String?
        var legs: [Leg] = []
        var bounds: Bounds?

        struct Leg: Decodable, Equatable {
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
            
            struct Step: Decodable, Equatable {
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
                
                struct Distance: Decodable, Equatable {
                    var value: Int?
                    var text: String?
                }

                struct Duration: Decodable, Equatable {
                    var value: Int?
                    var text: String?
                }
            }
        }

        struct Bounds: Decodable, Equatable {
            var northeast: LocationCoordinate2D?
            var southwest: LocationCoordinate2D?
        }
    }
    
    /// Represents a geocoded waypoint response.
    struct GeocodedWaypoint: Decodable, Equatable {
        enum GeocoderStatus: String, Decodable, Equatable {
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
    
    /// Represents the overall response from the Google Directions API.
    struct Response: Decodable, Equatable {
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

/// Accessor for the Google Directions Client in the dependency values.
extension DependencyValues {
    var googleDirectionsClient: GoogleDirectionsClient {
        get { self[GoogleDirectionsClient.self] }
        set { self[GoogleDirectionsClient.self] = newValue }
    }
}

/// Provides a live implementation of the Google Directions Client.
extension GoogleDirectionsClient: DependencyKey {
    static let liveValue: Self = {
        
        return Self(
            directions: { data in
                // Construct parameters and perform API request
                let request = GoogleDirectionRequest(
                    key: Configuration.current.directionKey,
                    origin: data.origin.toString(),
                    destination: data.destination.toString(),
                    mode: TravelMode.driving.rawValue.lowercased(),
                    region: Configuration.current.country
                )
                
                return try await API.provider.async
                    .request(.googleDirection(request))
                    .map(GoogleDirectionsClient.Response.self)
            }
        )
    }()
}
