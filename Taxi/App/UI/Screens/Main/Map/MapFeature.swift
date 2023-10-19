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
    }
    
    enum Action: Equatable {
        enum ViewAction: BindableAction, Equatable {
            case onViewLoad
            case onLocationButtonTap
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
    }
    
    @Dependency(\.locationManagerClient) var locationManagerClient
    @Dependency(\.applicationClient.open) var openURL
    @Dependency(\.googleGeocoderClient) var googleGeocoderClient
    
    private enum CancelID { case place }
    
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
                    .cancellable(id: CancelID.place)
                    
                case .binding:
                    return .none
                }
                
            case let .internalResponse(.location(location)):
                state.userLocation = location
                return .none
                
            case let .internalResponse(.geocode(data)):
                state.pickupSpot.address = data.thoroughfare
                return .none
                
            case .internal, .pickupSpot:
                return .none
            }
        }
        
        MapUserLocationFeature()
        GeocoderFeature()
    }
}
