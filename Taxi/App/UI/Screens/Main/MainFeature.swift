//
//  MainReducer.swift
//  Showcase
//
//  Created by Anatoli Petrosyants on 26.04.23.
//

import SwiftUI
import ComposableArchitecture

struct MainFeature: Reducer {
    
    struct State: Equatable {
        var sidebar = SidebarFeature.State()
    }
    
    enum Action: Equatable {
        case sidebar(SidebarFeature.Action)
        
        enum Delegate: Equatable {
            case didLogout
        }
        
        case delegate(Delegate)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.sidebar, action: /Action.sidebar) {
            SidebarFeature()
        }
        
        Reduce { state, action in
            switch action {
                
            case let .sidebar(.delegate(.didSidebarTapped(type))):
                switch type {
                case .logout:
                    return .send(.delegate(.didLogout))
                    
                default:
                    return .none
                }
                
            case .sidebar, .delegate:
                return .none
            }
        }
    }
}
