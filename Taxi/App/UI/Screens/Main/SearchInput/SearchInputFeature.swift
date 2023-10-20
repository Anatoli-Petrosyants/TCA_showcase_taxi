//
//  SearchInput.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 20.10.23.
//

import SwiftUI
import ComposableArchitecture
import Dependencies

struct SearchInputFeature: Reducer {
    
    struct State: Equatable {
        @BindingState var text = ""
        var isEditing = false
        var isLoading = false
    }
    
    enum Action: Equatable {
        enum ViewAction: BindableAction, Equatable {
            case onClear
            case binding(BindingAction<State>)
        }
        
        enum InternalAction: Equatable {
            case cancel
        }
        
        enum Delegate: Equatable {
            case didSearchQueryChanged(String)
            case didSearchQueryCleared
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(Delegate)
    }
    
    private enum CancelID { case search }
    
    @Dependency(\.mainQueue) var mainQueue
    
    var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)
        
        Reduce { state, action in
            switch action {
            // view actions
            case let .view(viewAction):
                switch viewAction {
                case .onClear:
                    state.text = ""
                    state.isEditing = false
                    return .send(.internal(.cancel))
                    
                case .binding(\.$text):
                    state.isEditing = !state.text.isEmpty

                    if state.text.isEmpty {
                        return .send(.internal(.cancel))
                    } else {
                        return .send(.delegate(.didSearchQueryChanged(state.text)))
                            .debounce(id: CancelID.search, for: 0.5, scheduler: self.mainQueue)
                    }
                    
                case .binding:
                    return .none
                }
                
            // internal actions
            case .internal(.cancel):
                return .concatenate([
                    .cancel(id: CancelID.search),
                    .send(.delegate(.didSearchQueryCleared))
                ])
              
            // delegate actions
            case .delegate:
                return .none
            }
        }
    }
}


