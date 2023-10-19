//
//  GooglePlacesClient.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 19.10.23.
//

import Foundation
import Dependencies

struct GooglePlacesResponse: Equatable, Decodable {
    var place: String
}

struct GooglePlacesRequest: Encodable {
    let latitude: Double
    let longitude: Double

    init(latitude: Double, longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
}

struct GooglePlacesClient {
    var places: @Sendable (GooglePlacesRequest) -> Void // async throws -> GooglePlacesResponse
}

extension DependencyValues {
    var googlePlacesClient: GooglePlacesClient {
        get { self[GooglePlacesClient.self] }
        set { self[GooglePlacesClient.self] = newValue }
    }
}

extension GooglePlacesClient: DependencyKey {
    static let liveValue: Self = {
        return Self(
            places: { data in
                //
            }
        )
    }()
}
