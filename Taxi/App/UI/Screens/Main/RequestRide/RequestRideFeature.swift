//
//  RequestRideFeature.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 09.11.23.
//

import SwiftUI
import ComposableArchitecture

struct RequestRideFeature: Reducer {
    
    struct State: Equatable {
        var vehicles = VehiclesFeature.State()
    }
    
    enum Action: Equatable {
        case vehicles(VehiclesFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.vehicles, action: /Action.vehicles) {
            VehiclesFeature()
        }
        
        Reduce { state, action in
            switch action {
            case .vehicles:
                return .none
            }
        }
    }
}
