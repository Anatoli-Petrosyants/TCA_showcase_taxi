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
        enum ViewAction: Equatable {
            case onVerifyTap
        }
        
        enum InternalAction: Equatable {
            
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case vehicles(VehiclesFeature.Action)
    }
    
    var body: some ReducerOf<Self> {
        Scope(state: \.vehicles, action: /Action.vehicles) {
            VehiclesFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onVerifyTap:
                    // let reason = "We need to authentication you for payment."
                    return .none
                }
                
            case .internal:
                return .none
                
            case .vehicles:
                return .none
            }
        }
    }
}
