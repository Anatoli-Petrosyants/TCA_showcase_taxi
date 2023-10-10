//
//  SidebarFeature.swift
//  Showcase
//
//  Created by Anatoli Petrosyants on 21.07.23.
//

import SwiftUI
import ComposableArchitecture

struct SidebarFeature: Reducer {
    
    enum SidebarItemType {
        case logout, share, contact, rate
    }
    
    struct State: Equatable, Hashable {
        var isVisible = false
        @BindingState var isSharePresented = false
    }
    
    enum Action: Equatable {
        enum ViewAction: BindableAction, Equatable {
            case onDismiss
            case onLogoutTap
            case onContactTap
            case onRateTap
            case onShareTap
            case onAppSettings
            case onDarkModeTap
            case binding(BindingAction<State>)
        }
        
        enum InternalAction: Equatable {
            case toggleVisibility
        }

        enum Delegate: Equatable {
            case didSidebarTapped(SidebarItemType)
        }

        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(Delegate)
    }        
    
    var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)
        SidebarLogic()
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onDismiss:
                    return .send(.internal(.toggleVisibility))
                    
                case .onLogoutTap:
                    return .concatenate(
                        .send(.internal(.toggleVisibility)),
                        .send(.delegate(.didSidebarTapped(.logout)))
                    )
                    
                case .onContactTap:
                    return .send(.internal(.toggleVisibility))
                    
                case .onRateTap:
                    return .send(.internal(.toggleVisibility))
                    
                case .onShareTap:
                    state.isSharePresented = true
                    return .none
                    
                case .onAppSettings:
                    return .none
                
                case .onDarkModeTap:
                    return .none

                case .binding:
                    return .none
                }
                
            case .internal(.toggleVisibility):
                state.isVisible.toggle()
                return .none

            case .delegate:
                return .none
            }
        }
    }
}

