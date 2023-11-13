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
            case localAuthenticationResponse(TaskResult<Bool>)
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case vehicles(VehiclesFeature.Action)
    }
    
    @Dependency(\.localAuthenticationClient) var localAuthenticationClient
    
    var body: some ReducerOf<Self> {
        Scope(state: \.vehicles, action: /Action.vehicles) {
            VehiclesFeature()
        }
        
        Reduce { state, action in
            switch action {
            case let .view(viewAction):
                switch viewAction {
                case .onVerifyTap:
                    return .run { send in
                        await send(
                            .internal(
                                .localAuthenticationResponse(
                                    await TaskResult {
                                        try await self.localAuthenticationClient.authenticate(
                                            "We need to authentication you for payment."
                                        )
                                    }
                                )
                            )
                        )
                    }
                }
                
            case let .internal(internalAction):
                switch internalAction {
                case let .localAuthenticationResponse(.success(data)):
                    Log.info("localAuthenticationResponse success: \(data)")
                    return .none
                    
                case let .localAuthenticationResponse(.failure(error)):
                    Log.error("localAuthenticationResponse failure: \(error)")
                    return .none
                }
                
            case .vehicles:
                return .none
            }
        }
    }
}
