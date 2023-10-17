//
//  MapUserLocationFeature.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 17.10.23.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation

struct MapUserLocationFeature<State>: Reducer {
    
    @Dependency(\.locationManagerClient) var locationManagerClient
    @Dependency(\.applicationClient.open) var openURL

    func reduce(into _: inout State, action: MapFeature.Action) -> Effect<MapFeature.Action> {
        switch action {
            
        case let .internal(internalAction):
            switch internalAction {
            case let .locationManager(.didUpdateLocations(locations)):
                Log.info("didUpdateLocations \(locations)")
                
                guard let location = locations.last else {
                    return .none
                }
                
                let locationAge = -(location.timestamp.timeIntervalSinceNow)
                if (locationAge > 5.0) {
                    return .none
                }
                
                return .send(.internal(.lastLocation(location)))
                
            case let .locationManager(.didChangeAuthorization(status)):
                Log.info("didChangeAuthorization \(status.description)")

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
                
            case .lastLocation:
                return .none
            }
            
        default:
            return .none
        
        }
    }
}
