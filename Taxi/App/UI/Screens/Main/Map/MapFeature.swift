//
//  MapFeature.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 10.10.23.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation
import GoogleMaps

struct MapFeature: Reducer {
    
    struct State: Equatable {
        var userLocation: CLLocation? = nil
        var pickupSpot = PickupSpotFeature.State()
        @PresentationState var whereTo: WhereToFeature.State?
    }
    
    enum Action: Equatable {
        enum ViewAction: BindableAction, Equatable {
            case onViewLoad
            case onLocationButtonTap
            case onWhereToButtonTap
            case onMapViewWillMove
            case onMapViewIdleAtPosition(GMSCameraPosition)
            case binding(BindingAction<State>)
        }
        
        enum InternalAction: Equatable {
            case updateLocation
            case locationManager(LocationManagerClient.DelegateEvent)
            case geocodeResponse(TaskResult<GoogleGeocoderResponse>)
        }
        
        enum InternalResponseAction: Equatable {
            case location(CLLocation)
            case geocode(GoogleGeocoderResponse)
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case internalResponse(InternalResponseAction)
        case pickupSpot(PickupSpotFeature.Action)
        case whereTo(PresentationAction<WhereToFeature.Action>)
    }
    
    @Dependency(\.locationManagerClient) var locationManagerClient
    @Dependency(\.applicationClient.open) var openURL
    @Dependency(\.googleGeocoderClient) var googleGeocoderClient
    
    private enum CancelID { case reverseGeocode }
    
    var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)
        
        Scope(state: \.pickupSpot, action: /Action.pickupSpot) {
            PickupSpotFeature()
        }
        
        Reduce { state, action in
            switch action {
            // view actions
            case let .view(viewAction):
                switch viewAction {
                case .onViewLoad:
                    let userLocationsEventStream = self.locationManagerClient.delegate()
                    return .run { send in
                        await withThrowingTaskGroup(of: Void.self) { group in
                            group.addTask {
                                for await event in userLocationsEventStream {
                                    await send(.internal(.locationManager(event)))
                                }
                            }
                        }
                    }
                    
                case .onLocationButtonTap:
                    return .send(.internal(.updateLocation))
                    
                case .onWhereToButtonTap:
                    state.whereTo = WhereToFeature.State()
                    return .none
                    
                case .onMapViewWillMove:
                    return .cancel(id: CancelID.reverseGeocode)
                    
                case let .onMapViewIdleAtPosition(position):
                    state.userLocation = nil
                    return .run { send in
                        await send(
                            .internal(
                                .geocodeResponse(
                                    await TaskResult {
                                        try await self.googleGeocoderClient.reverseGeocode(
                                            .init(coordinate: position.target)
                                        )
                                    }
                                )
                            )
                        )
                    }
                    .cancellable(id: CancelID.reverseGeocode)
                    
                case .binding:
                    return .none
                }
                
            case let .internalResponse(.location(location)):
                state.userLocation = location
                return .none
                
            case let .internalResponse(.geocode(data)):
                state.pickupSpot.address = data.thoroughfare
                return .none
                
            case let .whereTo(.presented(.delegate(whereToAction))):
                switch whereToAction {
                case let .didPlaceSelected(place):
                    Log.info("didPlaceSelected place \(place)")
                    return .none
                }
                
            case .internal, .pickupSpot, .whereTo:
                return .none
            }
        }
        .ifLet(\.$whereTo, action: /Action.whereTo) { WhereToFeature() }
        
        UserLocationFeature()
        GeocoderFeature()
    }
}
