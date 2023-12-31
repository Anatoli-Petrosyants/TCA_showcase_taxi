//
//  UserLocationFeature.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 17.10.23.
//

import SwiftUI
import ComposableArchitecture
import CoreLocation

struct UserLocationFeature<State>: Reducer {
    
    @Dependency(\.locationManagerClient) var locationManagerClient
    @Dependency(\.applicationClient.open) var openURL

    func reduce(into _: inout State, action: MapFeature.Action) -> Effect<MapFeature.Action> {
        switch action {
            
        case let .internal(internalAction):
            switch internalAction {
            case .updateLocation:
                // Log.info("locationManager updateLocation")
                locationManagerClient.startUpdatingLocation()
                return .none
                
            case let .locationManager(.didUpdateLocations(locations)):
                guard let location = locations.last else {
                    return .none
                }
                
                let locationAge = -(location.timestamp.timeIntervalSinceNow)
                if (locationAge > 5.0) {
                    return .none
                }
                
                // Log.info("locationManager didUpdateLocation \(location.coordinate)")
                
                locationManagerClient.stopUpdatingLocation()
                return .send(.internalResponse(.location(location)))
                
            case let .locationManager(.didChangeAuthorization(status)):
                // Log.info("locationManager didChangeAuthorization \(status.description)")

                switch status {
                case .notDetermined:
                    // locationManagerClient.requestAuthorization()
                    return .none

                case .denied, .restricted:
                    /*
                    // #dev show alert to open settings. A.P.
                    return .run { _ in
                        _ = await self.openURL(URL(string: UIApplication.openSettingsURLString)!, [:])
                    }
                    */
                    return .none

                case .authorizedAlways, .authorizedWhenInUse:
                    // Log.info("locationManager updateLocation")
                    locationManagerClient.startUpdatingLocation()
                    return .none

                default:
                    return .none
                }
                
            case let .locationManager(.didFailWithError(error)):
                Log.error("locationManager didFailWithError \(error.localizedDescription)")
                return .none
                
            default:
                return .none
            }
            
        default:
            return .none
        
        }
    }
}
