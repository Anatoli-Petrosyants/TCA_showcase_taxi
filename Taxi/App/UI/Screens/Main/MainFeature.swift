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
        var map = MapFeature.State()
    }
    
    enum Action: Equatable {
        enum ViewAction: Equatable {
            case onMenuTap
        }
        
        enum Delegate: Equatable {
            case didLogout
        }
        
        case view(ViewAction)
        case delegate(Delegate)
        case sidebar(SidebarFeature.Action)
        case map(MapFeature.Action)
    }
    
    var body: some Reducer<State, Action> {
        Scope(state: \.sidebar, action: /Action.sidebar) {
            SidebarFeature()
        }
        
        Scope(state: \.map, action: /Action.map) {
            MapFeature()
        }
        
        Reduce { state, action in
            switch action {
            // view actions
            case let .view(viewAction):
                switch viewAction {
                case .onMenuTap:
                    state.sidebar.isVisible.toggle()
                    return .none
                }
                
            // sidebar actions
            case let .sidebar(.delegate(.didSidebarTapped(type))):
                switch type {
                case .logout:
                    return .send(.delegate(.didLogout))
                    
                default:
                    return .none
                }
                
            case .sidebar, .map, .delegate:
                return .none
            }
        }
    }
}
