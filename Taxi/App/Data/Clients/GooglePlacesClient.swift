//
//  GooglePlacesClient.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 20.10.23.
//

import Foundation
import Dependencies
import GoogleMaps
import GooglePlaces

struct GoogleAutocompletePrediction: Equatable, Hashable {
    var placeID: String
    var attributedFullText: NSAttributedString
    
    var text: String {
        let array = attributedFullText.string.components(separatedBy: ",").dropLast()
        return array.joined(separator: ",")
    }
}

struct GooglePlacesResponse: Equatable {
    var googleAutocompletePredictions: [GoogleAutocompletePrediction]
}

struct GooglePlaceResponse: Equatable {
    var placeID: String
    var coordinate: CLLocationCoordinate2D
    var formattedAddress: String
}

struct GooglePlacesRequest {
    let query: String

    init(query: String) {
        self.query = query
    }
}

struct GooglePlacesClient {
    var autocompletePredictions: @Sendable (GooglePlacesRequest) async throws -> GooglePlacesResponse
    var lookUpPlaceID: @Sendable (String) async throws -> GooglePlaceResponse
}

extension DependencyValues {
    var googlePlacesClient: GooglePlacesClient {
        get { self[GooglePlacesClient.self] }
        set { self[GooglePlacesClient.self] = newValue }
    }
}

extension GooglePlacesClient: DependencyKey {
    static let liveValue: Self = {
        let token = GMSAutocompleteSessionToken.init()
        
        let filter = GMSAutocompleteFilter()
        filter.country = Configuration.current.country
        
        let placesClient = GMSPlacesClient()
        
        return Self(
            autocompletePredictions: { data in
                return try await withCheckedThrowingContinuation { continuation in
                    placesClient.findAutocompletePredictions(fromQuery: data.query,
                                                             filter: filter,
                                                             sessionToken: token) { (results, error) in
                        if let err = error {
                            continuation.resume(with: .failure(err))
                            return
                        }
                        
                        if let results = results {
                            let response = results.compactMap {
                                GoogleAutocompletePrediction(
                                    placeID: $0.placeID,
                                    attributedFullText: $0.attributedFullText
                                )
                            }
                            
                            continuation.resume(
                                returning: GooglePlacesResponse(googleAutocompletePredictions: response)
                            )
                        }
                    }
                }
            },
            lookUpPlaceID: { placeId in
                return try await withCheckedThrowingContinuation { continuation in
                    placesClient.lookUpPlaceID(placeId) { (place, error) in
                        Log.info("lookUpPlaceID \(placeId) placeId \(place?.placeID)")
                        Log.info("lookUpPlaceID \(placeId) coordinate \(place?.coordinate)")
                        Log.info("lookUpPlaceID \(placeId) formattedAddress \(place?.formattedAddress)")
                    }
                }
            }
        )
    }()
}
