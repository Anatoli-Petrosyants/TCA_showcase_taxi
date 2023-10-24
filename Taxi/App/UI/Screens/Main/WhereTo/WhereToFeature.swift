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
            case onPredictionTap(GoogleAutocompletePrediction)
        }
        
        enum InternalAction: Equatable {
            case googleAutocompletePredictionsResponse(TaskResult<GooglePlacesResponse>)
            case googlePlaceResponse(TaskResult<GooglePlaceResponse>)
        }
        
        enum DelegateAction: Equatable {
            case didPlaceSelected(GooglePlaceResponse)
        }

        case view(ViewAction)
        case `internal`(InternalAction)
        case delegate(DelegateAction)
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
                    
                case let .onPredictionTap(prediction):
                    state.input.isLoading = true
                    return .run { send in
                        await send(
                            .internal(
                                .googlePlaceResponse(
                                    await TaskResult {
                                        try await self.googlePlacesClient.lookUpPlaceID(prediction.placeID)
                                    }
                                )
                            )
                        )
                    }
                }
                
            case let .internal(internalAction):
                switch internalAction {
                case let .googleAutocompletePredictionsResponse(result):
                    switch result {
                    case let .success(data):
                        state.input.isLoading = false
                        state.data = .loaded(data.googleAutocompletePredictions)
                        return .none
                        
                    case let .failure(error):
                        Log.error("googlePlacesResponse: \(error)")
                        state.input.isLoading = false
                        state.data = .failed(error)
                        return .none
                    }
                    
                case let .googlePlaceResponse(result):
                    switch result {
                    case let .success(data):
                        state.input.isLoading = false
                        return .concatenate([
                            .send(.delegate(.didPlaceSelected(data))),
                            .run { _ in await self.dismiss() }
                        ])
                        
                    case let .failure(error):
                        Log.error("googlePlacesResponse: \(error)")
                        state.input.isLoading = false
                        state.data = .failed(error)
                        return .none
                    }
                }
                
            case let .input(inputAction):
                switch inputAction {
                case let .delegate(.didSearchQueryChanged(query)):
                    state.input.isLoading = true
                    return .run { send in
                        await send(
                            .internal(
                                .googleAutocompletePredictionsResponse(
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
                    state.data = .idle
                    return .cancel(id: CancelID.search)
                    
                default:
                    return .none
                }
                
            case .delegate:
                return .none
            }
        }
    }
}
