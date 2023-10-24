//
//  GooglePlacesClient.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 20.10.23.
//

import Foundation
import ComposableArchitecture
import Dependencies
import GooglePlaces

/// A client for interacting with Google Places services.
struct GooglePlacesClient {
    /// A closure for performing an autocomplete predictions request.
    var autocompletePredictions: @Sendable (GooglePlacesClient.AutocompletePredictionRequest) async throws -> [GooglePlacesClient.AutocompletePredictionResponse]

    /// A closure for performing a place lookup by place ID request.
    var lookUpPlaceID: @Sendable (String) async throws -> GooglePlacesClient.LookUpPlaceResponse
}

extension GooglePlacesClient {
    /// Response for autocomplete predictions.
    struct AutocompletePredictionResponse: Equatable, Hashable {
        var placeID: String
        var attributedFullText: NSAttributedString
        
        /// Extract the plain text from attributed full text.
        var text: String {
            let array = attributedFullText.string.components(separatedBy: ",").dropLast()
            return array.joined(separator: ",")
        }
    }
    
    /// Response for place lookup by place ID.
    struct LookUpPlaceResponse: Equatable {
        var placeID: String
        var coordinate: CLLocationCoordinate2D
        var formattedAddress: String
    }
}

extension GooglePlacesClient {
    /// Request for autocomplete predictions.
    struct AutocompletePredictionRequest {
        let query: String

        init(query: String) {
            self.query = query
        }
    }
}

extension DependencyValues {
    /// Accessor for the GooglePlacesClient in the dependency values.
    var googlePlacesClient: GooglePlacesClient {
        get { self[GooglePlacesClient.self] }
        set { self[GooglePlacesClient.self] = newValue }
    }
}

extension GooglePlacesClient: DependencyKey {
    /// A live implementation of GooglePlacesClient.
    static let liveValue: Self = {
        let filter = GMSAutocompleteFilter()
        filter.country = Configuration.current.country
        
        let placesClient = GMSPlacesClient()
        
        return Self(
            autocompletePredictions: { data in
                return try await withCheckedThrowingContinuation { continuation in
                    placesClient.findAutocompletePredictions(fromQuery: data.query,
                                                             filter: filter,
                                                             sessionToken: .init()) { (results, error) in
                        if let err = error {
                            continuation.resume(with: .failure(err))
                            return
                        }
                        
                        if let results = results {
                            let response = results.compactMap {
                                GooglePlacesClient.AutocompletePredictionResponse(
                                    placeID: $0.placeID,
                                    attributedFullText: $0.attributedFullText
                                )
                            }
                            
                            continuation.resume(returning:  response)
                        }
                    }
                }
            },
            lookUpPlaceID: { placeId in
                return try await withCheckedThrowingContinuation { continuation in
                    placesClient.lookUpPlaceID(placeId) { (place, error) in
                        if let err = error {
                            continuation.resume(with: .failure(err))
                            return
                        }
                        
                        if let place = place {
                            let response = GooglePlacesClient.LookUpPlaceResponse(
                                placeID: place.placeID.valueOr(""),
                                coordinate: place.coordinate,
                                formattedAddress: place.formattedAddress.valueOr("")
                            )
                            
                            continuation.resume(returning: response)
                        }
                    }
                }
            }
        )
    }()
}
