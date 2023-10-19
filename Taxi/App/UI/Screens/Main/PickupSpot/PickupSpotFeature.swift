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
        case onViewAppear
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onViewAppear:
                return .none
            }
        }
    }
}
