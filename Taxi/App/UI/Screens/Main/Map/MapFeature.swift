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
        
    }
    
    enum Action: Equatable {
        enum ViewAction: Equatable {
            case onViewLoad
            case onLocationButtonTap
        }
        
        enum InternalAction: Equatable {
            case locationManager(LocationManagerClient.DelegateEvent)
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
                    Log.debug("onViewLoad")
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
                
                
            case let .internal(internalAction):
                switch internalAction {
                case let .locationManager(.didUpdateLocations(locations)):
                    Log.debug("didUpdateLocations \(locations)")
                    return .none
                    
                case let .locationManager(.didChangeAuthorization(status)):
                    Log.debug("didChangeAuthorization \(status.description)")

                    switch status {
                    case .notDetermined:
                        locationManagerClient.requestAuthorization()
                        return .none

                    case .denied, .restricted:
                        return .run { _ in
                            _ = await self.openURL(URL(string: UIApplication.openSettingsURLString)!, [:])
                        }

                    case .authorizedAlways, .authorizedWhenInUse:
                        locationManagerClient.startUpdatingLocation()
                        return .none

                    default:
                        return .none
                    }
                    
                case let .locationManager(.didFailWithError(error)):
                    Log.debug("didFailWithError \(error.localizedDescription)")
                    return .none
                }
            }
        }
    }
}

//struct MapFeature: Reducer {
//
//    struct State: Equatable {
//
//    }
//
//    enum Action: BindableAction, Equatable {
//        enum ViewAction: Equatable {
//            case onViewLoad
//            case onLocationButtonTap
//        }
//
//        enum InternalAction: Equatable {
//            case requestLocation
//            case locationManager(LocationManagerClient.DelegateEvent)
//        }
//
//        case view(ViewAction)
//        case binding(BindingAction<State>)
//        case `internal`(InternalAction)
//    }
//
//    @Dependency(\.locationManagerClient) var locationManagerClient
//    @Dependency(\.applicationClient.open) var openURL
//
//    var body: some Reducer<State, Action> {
//        BindingReducer()
//
//        Reduce { state, action in
//            switch action {
//            // view actions
//            case let .view(viewAction):
//                switch viewAction {
//                case .onViewLoad:
//                    Log.debug("isLocationEnabled: \(locationManagerClient.authorizationStatus())")
//
////                    let userLocationsEventStream = self.locationManagerClient.delegate()
////                    return .run { send in
////                        await withThrowingTaskGroup(of: Void.self) { group in
////                            group.addTask {
////                                for await event in userLocationsEventStream {
////                                    await send(.internal(.locationManager(event)))
////                                }
////                            }
////                        }
////                    }
//
//                    return .none
//
//                case .onLocationButtonTap:
//                    Log.debug("onLocationButtonTap")
//                    return .send(.internal(.requestLocation))
//                }
//
//            // internal actions
//            case let .internal(internalAction):
//                Log.debug("internal \(internalAction)")
//                return .none
//
////                switch internalAction {
////                case .requestLocation:
////
//                    let status = locationManagerClient.authorizationStatus()
//                    Log.debug("requestLocation status \(status)")
////
////                    switch status {
////                    case .notDetermined:
////                        locationManagerClient.requestAuthorization()
////                        return .none
////
////                    case .restricted, .denied:
////                        return .run { _ in
////                            _ = await self.openURL(URL(string: UIApplication.openSettingsURLString)!, [:])
////                        }
////
////                    case .authorizedWhenInUse, .authorizedAlways:
////                        locationManagerClient.requestLocation()
////                        return .none
////
////                    default:
////                        return .none
////                    }
////
////                case let .locationManager(.didUpdateLocations(locations)):
////                    Log.debug("locations \(locations)")
////                    return .none
////
////                }
//
//            case .binding:
//                return .none
//            }
//        }
//    }
//}

// let projection = mapView.projection
// let centerPoint = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: 200)
// Log.info("idleAt projection \(projection.coordinate(for: centerPoint))")

// https://github.com/googlemaps-samples/maps-sdk-for-ios-samples/issues/58

//    @State private var region = MKCoordinateRegion(
//        center: CLLocationCoordinate2D(latitude: 40.183974823578815,
//                                       longitude: 44.51509883139478),
//        span: MKCoordinateSpan(latitudeDelta: 0.001,
//                               longitudeDelta: 0.001))
