//
//  MapFeature.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 10.10.23.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation

struct MapFeature: Reducer {
    
    struct State: Equatable {
        @BindingState var userLocation: CLLocation? = nil
    }
    
    enum Action: Equatable {
        enum ViewAction: BindableAction, Equatable {
            case onViewLoad
            case binding(BindingAction<State>)
        }
        
        enum InternalAction: Equatable {
            case locationManager(LocationManagerClient.DelegateEvent)
            case lastUserLocation(CLLocation)
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
    }
    
    @Dependency(\.locationManagerClient) var locationManagerClient
    @Dependency(\.applicationClient.open) var openURL
    
    var body: some ReducerOf<Self> {
        BindingReducer(action: /Action.view)
        
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
                    
                case .binding:
                    return .none
                }
                
            case let .internal(.lastUserLocation(location)):
                state.userLocation = location
                return .none
                
            case .internal:
                return .none
            }
        }
        
        MapUserLocationFeature()
    }
}


// let projection = mapView.projection
// let centerPoint = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: 200)
// Log.info("idleAt projection \(projection.coordinate(for: centerPoint))")

// https://github.com/googlemaps-samples/maps-sdk-for-ios-samples/issues/58
