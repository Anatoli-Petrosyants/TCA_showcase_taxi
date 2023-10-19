//
//  GooglePlacesFeature.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 19.10.23.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation

struct GooglePlacesFeature<State>: Reducer {

    func reduce(into _: inout State, action: MapFeature.Action) -> Effect<MapFeature.Action> {
        switch action {
            
        case let .internal(internalAction):
            switch internalAction {
            
            case let .placesResponse(.success(data)):
                Log.info("placesResponse: \(data)")
                return .none
                
            case let .placesResponse(.failure(error)):
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
