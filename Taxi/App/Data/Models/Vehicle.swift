//
//  Vehicle.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 09.11.23.
//

import Foundation

/// Enum representing different types of vehicles.
enum VehicleType: String, CaseIterable {
    case econom
    case comfort
    case business
    case minivan
    case truck
    case evacuator
}

/// Struct representing a vehicle with an ID and a type.
struct Vehicle: Identifiable, Equatable, Hashable {
    var id = UUID()
    var type: VehicleType
}

extension Vehicle {
    /// Computed property to get the human-readable title of the vehicle based on its type.
    var title: String {
        switch type {
        case .econom: return "Econom"
        case .comfort: return "Comfort"
        case .business: return "Business"
        case .minivan: return "Minivan"
        case .truck: return "Truck"
        case .evacuator: return "Evacuator"
        }
    }
    
    /// Computed property to get the icon name of the vehicle based on its type.
    var icon: String {
        return "ic_vehicle_" + type.rawValue
    }
}

extension Vehicle {
    /// Static property to get an array of all possible vehicles.
    static let all: [Vehicle] = VehicleType.allCases.map { Vehicle(type: $0) }
}
