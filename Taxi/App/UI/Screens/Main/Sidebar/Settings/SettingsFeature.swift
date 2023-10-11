//
//  SettingsFeature.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 10.10.23.
//


import SwiftUI
import ComposableArchitecture

struct SettingsFeature: Reducer {
    
    struct State: Equatable {
        
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
