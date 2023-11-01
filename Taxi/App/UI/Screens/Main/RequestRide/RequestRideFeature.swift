//
//  RequestRideFeature.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 31.10.23.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation

struct RequestRideFeature: Reducer {
    
    struct State: Equatable {
        var startCoordinate: CLLocationCoordinate2D
        var endCoordinate: CLLocationCoordinate2D
        
        var polylinePoints: [String] = []
        var overviewPolylinePoint: String? = nil
    }
    
    enum Action: Equatable {
        enum ViewAction: Equatable {
            case onViewLoad
        }
        
        enum InternalAction: Equatable {
            case directionsResponse(TaskResult<GoogleDirectionsClient.Response>)
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
    }
    
    @Dependency(\.googleDirectionsClient) var googleDirectionsClient
    
    var body: some ReducerOf<Self> {
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
            case let .internal(internalAction):
                switch internalAction {
                case let .directionsResponse(.success(data)):
                    guard data.status == GoogleDirectionsClient.StatusCode.ok else {
                        Log.error("directionsResponse success: \(data.errorMessage.valueOr(""))")
                        return .none
                    }
                    
                    let points = data.routes.map {
                        $0.legs.compactMap {
                            $0.steps.compactMap {
                                $0.polyline?.points
                            }
                        }
                    }.reduce([], +).reduce([], +)
                    
                    state.polylinePoints = points
                    state.overviewPolylinePoint = data.routes[0].overviewPolyline?.points

                    return .none
                    
                case let .directionsResponse(.failure(error)):
                    Log.error("directionsResponse failure: \(error)")
                    return .none
                }
            }
        }
    }
}
