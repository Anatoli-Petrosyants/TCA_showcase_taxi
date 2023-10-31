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
        var startCoordinate: CLLocationCoordinate2D? = nil
        var endCoordinate: CLLocationCoordinate2D? = nil
        
        var pickupSpot = PickupSpotFeature.State()
        @PresentationState var whereTo: WhereToFeature.State?
        
        var path = StackState<Path.State>()
    }
    
    enum Action: Equatable {
        enum ViewAction: BindableAction, Equatable {
            case onViewLoad
            case onLocationButtonTap
            case onWhereToButtonTap
            case onMapViewWillMove
            case onMapViewIdleAtPosition(GMSCameraPosition)
            case onRequestButtonTap
            case binding(BindingAction<State>)
        }
        
        enum InternalAction: Equatable {
            case updateLocation
            case locationManager(LocationManagerClient.DelegateEvent)
            case geocodeResponse(TaskResult<GoogleGeocoderClient.Response>)
            case directionsResponse(TaskResult<GoogleDirectionsClient.Response>)
        }
        
        enum InternalResponseAction: Equatable {
            case location(CLLocation)
            case geocode(GoogleGeocoderClient.Response)
//            case directions([String])
        }
        
        case view(ViewAction)
        case `internal`(InternalAction)
        case internalResponse(InternalResponseAction)
        case pickupSpot(PickupSpotFeature.Action)
        case whereTo(PresentationAction<WhereToFeature.Action>)
        case path(StackAction<Path.State, Path.Action>)
    }
    
    struct Path: Reducer {
        enum State: Equatable {
            case requestRide(RequestRideFeature.State)
        }
        
        enum Action: Equatable {
            case requestRide(RequestRideFeature.Action)
        }
        
        var body: some Reducer<State, Action> {
            Scope(state: /State.requestRide, action: /Action.requestRide) {
                RequestRideFeature()
            }
        }
    }
    
    @Dependency(\.locationManagerClient) var locationManagerClient
    @Dependency(\.applicationClient.open) var openURL
    @Dependency(\.googleGeocoderClient) var googleGeocoderClient
    @Dependency(\.googleDirectionsClient) var googleDirectionsClient
    
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
                    state.startCoordinate = position.target
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
                    
                case .onRequestButtonTap:
                    state.path.append(
                        .requestRide(
                            .init()
                        )
                    )
                    return .none
                    
                case .binding:
                    return .none
                }
                
            case let .internalResponse(.location(location)):
                state.userLocation = location
                return .none
                
            case let .internalResponse(.geocode(data)):
                state.pickupSpot.address = data.thoroughfare
                return .none
                
//            case let .internalResponse(.directions(data)):
//                return .none
                
            case let .whereTo(.presented(.delegate(whereToAction))):
                switch whereToAction {
                case let .didPlaceSelected(place):
                    return .none
//                    state.endCoordinate = place.coordinate
//                    
//                    let origin = GoogleDirectionsClient.Request.Place.coordinate(
//                        coordinate: GoogleDirectionsClient.LocationCoordinate2D(
//                            latitude: state.startCoordinate!.latitude,
//                            longitude: state.startCoordinate!.longitude
//                        )
//                    )
//
//                    let destination = GoogleDirectionsClient.Request.Place.coordinate(
//                        coordinate: GoogleDirectionsClient.LocationCoordinate2D(
//                            latitude: state.endCoordinate!.latitude,
//                            longitude: state.endCoordinate!.longitude
//                        )
//                    )
//                    
//                    return .run { send in
//                        await send(
//                            .internal(
//                                .directionsResponse(
//                                    await TaskResult {
//                                        try await self.googleDirectionsClient.directions(
//                                            .init(origin: origin, destination: destination)
//                                        )
//                                    }
//                                )
//                            )
//                        )
//                    }
                }
                
            case .internal, .pickupSpot, .whereTo, .path:
                return .none
            }
        }
        .ifLet(\.$whereTo, action: /Action.whereTo) { WhereToFeature() }
        .forEach(\.path, action: /Action.path) {
            Path()
        }
        
        UserLocationFeature()
        GeocoderFeature()
        // DirectionsFeature()
    }
}
