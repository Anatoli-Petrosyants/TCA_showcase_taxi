//
//  PickupSpotFeature.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 18.10.23.
//

import SwiftUI
import ComposableArchitecture

struct PickupSpotFeature: Reducer {
    
    struct State: Equatable {
        var address: String = "Move the map"
    }
    
    enum Action: Equatable {
        enum ViewAction: Equatable {
            case onGoButtonTap
        }
        
        enum DelegateAction: Equatable {
            case didRideRequested
        }
        
        case view(ViewAction)
        case delegate(DelegateAction)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .view(.onGoButtonTap):
                return .send(.delegate(.didRideRequested))

            case .delegate:
                return .none
            }
        }
    }
}
