//
//  AppleGeocoderClient.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 20.10.23.
//

import Foundation
import Dependencies
import CoreLocation

// Struct to represent the response from the Apple Geocoder service
struct AppleGeocoderResponse: Equatable, Decodable {
    var thoroughfare: String
    var latitude: Double
    var longitude: Double
}

// Struct to hold the request data for reverse geocoding
struct AppleGeocoderRequest {

    let coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

// Client for interacting with the Apple Geocoder service
struct AppleGeocoderClient {
    var reverseGeocode: @Sendable (AppleGeocoderRequest) async throws -> AppleGeocoderResponse
}

extension DependencyValues {
    /// Accessor for the AppleGeocoderClient in the dependency values.
    var appleGeocoderClient: AppleGeocoderClient {
        get { self[AppleGeocoderClient.self] }
        set { self[AppleGeocoderClient.self] = newValue }
    }
}

// Extension to make AppleGeocoderClient a DependencyKey
extension AppleGeocoderClient: DependencyKey {
    static let liveValue: Self = {
        let geocoder = CLGeocoder()
        
        return Self(
            reverseGeocode: { data in
                return try await withCheckedThrowingContinuation { continuation in
                    let location = CLLocation(latitude: data.coordinate.latitude,
                                              longitude: data.coordinate.longitude)
                    
                    geocoder.reverseGeocodeLocation(location, preferredLocale: .current) { placemarks, error in
                        if let err = error {
                            continuation.resume(with: .failure(err))
                        } else {
                            guard let placemarks = placemarks, let placemark = placemarks.first else {
                                return
                            }

                            /*
                            print("\ncoordinate.latitude=\(placemark.location!.coordinate.latitude)")
                            print("coordinate.longitude=\(placemark.location!.coordinate.longitude)")
                            print("thoroughfare=\(placemark.thoroughfare.valueOr(""))")
                            */
                            
                            let place = AppleGeocoderResponse(
                                thoroughfare: placemark.thoroughfare.valueOr(""),
                                latitude: placemark.location!.coordinate.latitude,
                                longitude: placemark.location!.coordinate.longitude
                            )
                            continuation.resume(returning: place)
                        }
                    }
                }
            }
        )
    }()
}
