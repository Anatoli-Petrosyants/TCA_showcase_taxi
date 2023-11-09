//
//  RequestMapFeature.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 31.10.23.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation

struct RequestMapFeature: Reducer {
    
    struct State: Equatable {
        var startCoordinate: CLLocationCoordinate2D
        var endCoordinate: CLLocationCoordinate2D
        
        var polylinePoints: [String] = []
        var overviewPolylinePoint: String? = nil
        
        var requestRide = RequestRideFeature.State()
    }
    
    enum Action: Equatable {
        enum ViewAction: Equatable {
            case onViewLoad
        }
        
        enum InternalAction: Equatable {
            case directionsResponse(TaskResult<GoogleDirectionsClient.Response>)
            case directionsPoints([String], String?)
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case requestRide(RequestRideFeature.Action)
    }
    
    @Dependency(\.googleDirectionsClient) var googleDirectionsClient
    
    var body: some ReducerOf<Self> {
        Scope(state: \.requestRide, action: /Action.requestRide) {
            RequestRideFeature()
        }
        
        Reduce { state, action in
            switch action {
            // view actions
            case let .view(viewAction):
                switch viewAction {
                case .onViewLoad:
                    let origin = GoogleDirectionsClient.Request.Place.coordinate(
                        coordinate: GoogleDirectionsClient.LocationCoordinate2D(
                            latitude: state.startCoordinate.latitude,
                            longitude: state.startCoordinate.longitude
                        )
                    )

                    let destination = GoogleDirectionsClient.Request.Place.coordinate(
                        coordinate: GoogleDirectionsClient.LocationCoordinate2D(
                            latitude: state.endCoordinate.latitude,
                            longitude: state.endCoordinate.longitude
                        )
                    )
                    
                    return .run { send in
                        await send(
                            .internal(
                                .directionsResponse(
                                    await TaskResult {
                                        try await self.googleDirectionsClient.directions(
                                            .init(origin: origin, destination: destination)
                                        )
                                    }
                                )
                            )
                        )
                    }
                }
                
            // internal actions
            case let .internal(.directionsPoints(polylinePoints, overviewPolylinePoint)):
                state.polylinePoints = polylinePoints
                state.overviewPolylinePoint = overviewPolylinePoint
                return .none                
                
            case .internal:
                return .none
                
            case .requestRide:
                return .none
            }
        }
        
        DirectionsFeature()
    }
}
