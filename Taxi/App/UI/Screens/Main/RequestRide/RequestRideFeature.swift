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
//        var startCoordinate: CLLocationCoordinate2D? = nil
//        var endCoordinate: CLLocationCoordinate2D? = nil
    }
    
    enum Action: Equatable {
        enum ViewAction: Equatable {
            case onViewLoad
        }
        
        enum InternalAction: Equatable {
            case directionsResponse(TaskResult<GoogleDirectionsClient.Response>)
        }
        
//        enum InternalResponseAction: Equatable {
//            case points([String])
//        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                // view actions
            case let .view(viewAction):
                switch viewAction {
                case .onViewLoad:
                    return .none
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
                    
                    // return .send(.internalResponse(.directions(points)))
                    return .none
                    
                case let .directionsResponse(.failure(error)):
                    Log.error("directionsResponse failure: \(error)")
                    return .none
                }
            }
        }
    }
}

//let origin = GoogleDirectionsClient.Request.Place.coordinate(
//    coordinate: GoogleDirectionsClient.LocationCoordinate2D(
//        latitude: state.startCoordinate!.latitude,
//        longitude: state.startCoordinate!.longitude
//    )
//)
//
//let destination = GoogleDirectionsClient.Request.Place.coordinate(
//    coordinate: GoogleDirectionsClient.LocationCoordinate2D(
//        latitude: state.endCoordinate!.latitude,
//        longitude: state.endCoordinate!.longitude
//    )
//)
//
//return .run { send in
//    await send(
//        .internal(
//            .directionsResponse(
//                await TaskResult {
//                    try await self.googleDirectionsClient.directions(
//                        .init(origin: origin, destination: destination)
//                    )
//                }
//            )
//        )
//    )
//}
