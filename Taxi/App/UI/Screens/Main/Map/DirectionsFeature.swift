//
//  DirectionsFeature.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 30.10.23.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation

struct DirectionsFeature<State>: Reducer {

    func reduce(into _: inout State, action: MapFeature.Action) -> Effect<MapFeature.Action> {
        switch action {
            
        case let .internal(internalAction):
            switch internalAction {
            case let .directionsResponse(.success(data)):
                return .send(.internalResponse(.directions(data)))
                
            case let .directionsResponse(.failure(error)):
                Log.error("directionsResponse: \(error)")
                return .none
                
            default:
                return .none
            }
            
        default:
            return .none
        
        }
    }
}

// https://maps.googleapis.com/maps/api/directions/json?destination=Yerevan&origin=Dilijan&region=am&mode=driving&key=AIzaSyC--Qx9Rx1bpKOsM-MxvAVEzq67eo6UiPc

//        GoogleMapsDirections.direction(fromOrigin: origin, toDestination: destination)
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
