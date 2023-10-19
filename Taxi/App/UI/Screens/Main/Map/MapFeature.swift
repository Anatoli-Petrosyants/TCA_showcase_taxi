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
            case lastUserLocation(CLLocation)
            
            case placesResponse(TaskResult<GooglePlacesResponse>)
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case pickupSpot(PickupSpotFeature.Action)
    }
    
    @Dependency(\.locationManagerClient) var locationManagerClient
    @Dependency(\.applicationClient.open) var openURL
    
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
                    let target = position.target
                    state.userLocation = nil
                    state.pickupSpot.address = "\(target.latitude), \(target.longitude)"
                    return .none
                    
                case .binding:
                    return .none
                }
                
            case let .internal(.lastUserLocation(location)):
                state.userLocation = location
                return .none
                
            case .internal, .pickupSpot:
                return .none
            }
        }
        
        MapUserLocationFeature()
        GooglePlacesFeature()
    }
}
