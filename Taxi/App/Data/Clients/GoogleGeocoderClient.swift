//
//  GooglePlacesClient.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 19.10.23.
//

import Foundation
import Dependencies
import GoogleMaps
import GooglePlaces

struct GoogleGeocoderResponse: Equatable, Decodable {
    var thoroughfare: String
}

struct GoogleGeocoderRequest {
    let coordinate: CLLocationCoordinate2D

    init(coordinate: CLLocationCoordinate2D) {
        self.coordinate = coordinate
    }
}

struct GoogleGeocoderClient {
    var reverseGeocode: @Sendable (GoogleGeocoderRequest) async throws -> GoogleGeocoderResponse
}

extension DependencyValues {
    var googleGeocoderClient: GoogleGeocoderClient {
        get { self[GoogleGeocoderClient.self] }
        set { self[GoogleGeocoderClient.self] = newValue }
    }
}

extension GoogleGeocoderClient: DependencyKey {
    static let liveValue: Self = {
        let geocoder = GMSGeocoder()
        
        return Self(
            reverseGeocode: { data in
                return try await withCheckedThrowingContinuation { continuation in
                    geocoder.reverseGeocodeCoordinate(data.coordinate) { response, error in
                        if let err = error {
                            continuation.resume(with: .failure(err))
                        } else {
                            guard let response = response, let address = response.firstResult() else {
                                continuation.resume(with: .failure(AppError.general))
                                return
                            }

                            /*
                            print("\ncoordinate.latitude=\(address.coordinate.latitude)")
                            print("coordinate.longitude=\(address.coordinate.longitude)")
                            print("thoroughfare=\(address.thoroughfare)")
                            print("locality=\(address.locality)")
                            print("subLocality=\(address.subLocality)")
                            print("administrativeArea=\(address.administrativeArea)")
                            print("postalCode=\(address.postalCode)")
                            print("country=\(address.country)")
                            print("lines=\(address.lines)")
                            print("addressLine1=\(address.addressLine1())")                            
                            */
                            
                            let place = GoogleGeocoderResponse(thoroughfare: address.thoroughfare.valueOr(""))
                            continuation.resume(returning: place)
                        }
                    }
                }
            }
        )
    }()
}
