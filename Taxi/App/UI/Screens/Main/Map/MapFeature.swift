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
        var lastLocation: CLLocation? = nil
    }
    
    enum Action: Equatable {
        enum ViewAction: Equatable {
            case onViewLoad
            case onLocationButtonTap
        }
        
        enum InternalAction: Equatable {
            case locationManager(LocationManagerClient.DelegateEvent)
            case lastLocation(CLLocation)
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
    }
    
    @Dependency(\.locationManagerClient) var locationManagerClient
    @Dependency(\.applicationClient.open) var openURL
    
    var body: some ReducerOf<Self> {
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
                    Log.debug("onLocationButtonTap")
                    return .none
                }
                
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
