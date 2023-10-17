//
//  LocationManagerClient.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 17.10.23.
//

import ComposableArchitecture
import Dependencies
import CoreLocation

struct LocationManagerClient {
    // Request location authorization
    var requestAuthorization: @Sendable () -> Void
    // Get the current authorization status
    var authorizationStatus: @Sendable () -> CLAuthorizationStatus
    // Start updating the device's location
    var startUpdatingLocation: @Sendable () -> Void
    // Stop updating the device's location
    var stopUpdatingLocation: @Sendable () -> Void
    // Provide a stream of delegate events
    var delegate: @Sendable () -> AsyncStream<DelegateEvent>
    
    // Delegate events that the CLLocationManager may produce
    enum DelegateEvent: Equatable {
        case didUpdateLocations([CLLocation])
        case didChangeAuthorization(CLAuthorizationStatus)
        case didFailWithError(Error)

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.didUpdateLocations(lhs), .didUpdateLocations(rhs)):
                return lhs == rhs
            case let (.didChangeAuthorization(lhs), .didChangeAuthorization(rhs)):
                return lhs == rhs
            default:
                return false
            }
        }
    }
}

extension DependencyValues {
    /// Accessor for the LocationManagerClient in the dependency values.
    var locationManagerClient: LocationManagerClient {
        get { self[LocationManagerClient.self] }
        set { self[LocationManagerClient.self] = newValue }
    }
}

extension LocationManagerClient: DependencyKey {
    /// A live implementation of LocationManagerClient.
    static let liveValue: LocationManagerClient = {

        let manager = CLLocationManager()
        manager.desiredAccuracy = kCLLocationAccuracyBest
        
        return Self (
            requestAuthorization: { manager.requestWhenInUseAuthorization() },
            authorizationStatus: { manager.authorizationStatus },
            startUpdatingLocation: { manager.startUpdatingLocation() },
            stopUpdatingLocation: { manager.stopUpdatingLocation() },
            delegate: {
                AsyncStream { continuation in
                    let delegate = Delegate(continuation: continuation)
                    manager.delegate = delegate
                    continuation.onTermination = { _ in
                        _ = delegate
                    }
                }
            }
        )
    }()
}

extension LocationManagerClient {
    fileprivate class Delegate: NSObject, CLLocationManagerDelegate {
        let continuation: AsyncStream<LocationManagerClient.DelegateEvent>.Continuation
        
        init(continuation: AsyncStream<LocationManagerClient.DelegateEvent>.Continuation) {
            self.continuation = continuation
        }
        
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.last else { return }
            
            let locationAge = -(location.timestamp.timeIntervalSinceNow)
            if (locationAge > 5.0) {
                return
            }
            
            // Yield the didUpdateLocations event
            self.continuation.yield(.didUpdateLocations(locations))
        }

        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            // Yield the didChangeAuthorization event
            self.continuation.yield(.didChangeAuthorization(status))
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            manager.stopUpdatingLocation()
            // Yield the didFailWithError event
            self.continuation.yield(.didFailWithError(error))
        }
    }
}

extension CLAuthorizationStatus {
    var description: String {
        switch self {
        case .notDetermined:
            return "Not Determined"
        case .authorized:
            return "Authorized"
        case .authorizedAlways:
            return "Authorized Always"
        case .authorizedWhenInUse:
            return "Authorized When In Use"
        case .denied:
            return "Denied"
        case .restricted:
            return "Restricted"
        default:
            return "Unknown"
        }
    }
}

