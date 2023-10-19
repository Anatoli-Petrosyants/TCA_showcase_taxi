//
//  GeocoderFeature.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 19.10.23.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation

struct GeocoderFeature<State>: Reducer {

    func reduce(into _: inout State, action: MapFeature.Action) -> Effect<MapFeature.Action> {
        switch action {
            
        case let .internal(internalAction):
            switch internalAction {
            
            case let .geocodeResponse(.success(data)):
                Log.info("placesResponse: \(data)")
                return .send(.internalResponse(.place(data)))
                
            case let .geocodeResponse(.failure(error)):
                Log.error("placesResponse: \(error)")
                return .none
                
            default:
                return .none
            }
            
        default:
            return .none
        
        }
    }
}
