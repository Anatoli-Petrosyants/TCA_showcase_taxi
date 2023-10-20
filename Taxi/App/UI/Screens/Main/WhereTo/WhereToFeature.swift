//
//  WhereToFeature.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 20.10.23.
//

import SwiftUI
import ComposableArchitecture

struct WhereToFeature: Reducer {
    
    struct State: Equatable {
        var input = SearchInputFeature.State()
    }
    
    enum Action: Equatable {
        case onCancelTap
        case input(SearchInputFeature.Action)
    }
    
    private enum CancelID { case search }
    
    @Dependency(\.dismiss) var dismiss
    
    var body: some ReducerOf<Self> {
        Scope(state: \.input, action: /Action.input) {
            SearchInputFeature()
        }

        Reduce { state, action in
            switch action {
                
            case .onCancelTap:
                return .run { _ in await self.dismiss() }
                
            case .input:
                return .none
            }
        }
    }
}
