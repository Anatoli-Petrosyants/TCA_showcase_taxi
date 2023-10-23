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
        var data: Loadable<[GoogleAutocompletePrediction]> = .idle
    }
    
    enum Action: Equatable {
        enum ViewAction: Equatable {
            case onCancelTap
        }
        
        enum InternalAction: Equatable {
            case googlePlacesResponse(TaskResult<GooglePlacesResponse>)
        }

        case view(ViewAction)
        case `internal`(InternalAction)
        case input(SearchInputFeature.Action)
    }
    
    private enum CancelID { case search }
    
    @Dependency(\.dismiss) var dismiss
    @Dependency(\.googlePlacesClient) var googlePlacesClient
    
    var body: some ReducerOf<Self> {
        Scope(state: \.input, action: /Action.input) {
            SearchInputFeature()
        }

        Reduce { state, action in
            switch action {                
            case let .view(viewAction):
                switch viewAction {
                case .onCancelTap:
                    return .concatenate([
                        .cancel(id: CancelID.search),
                        .run { _ in await self.dismiss() }
                    ])
                }
                
            case let .internal(internalAction):
                switch internalAction {
                case let .googlePlacesResponse(.success(data)):
                    Log.info("googlePlacesResponse: \(data)")
                    state.data = .loaded(data.googleAutocompletePredictions)
                    return .none
                    
                case let .googlePlacesResponse(.failure(error)):
                    Log.error("googlePlacesResponse: \(error)")
                    return .none
                }
                
            case let .input(inputAction):
                switch inputAction {
                case let .delegate(.didSearchQueryChanged(query)):
                    Log.info("didSearchQueryChanged query: \(query)")
                    return .run { send in
                        await send(
                            .internal(
                                .googlePlacesResponse(
                                    await TaskResult {
                                        try await self.googlePlacesClient.autocompletePredictions(
                                            .init(query: query)
                                        )
                                    }
                                )
                            )
                        )
                    }
                    .cancellable(id: CancelID.search)

                case .delegate(.didSearchQueryCleared):
                    return .cancel(id: CancelID.search)
                    
                default:
                    return .none
                }
            }
        }
    }
}
