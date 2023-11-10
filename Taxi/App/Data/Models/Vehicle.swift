//
//  Vehicle.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 09.11.23.
//

import Foundation

enum VehicleType {
    case econom
    case comfort
    case business
    case minivan
    case truck
    case evacuator
}

//extension VehicleType {
//    var icon: Image {
//        switch self {
//        case .econom:
//            "Econom"
//        case .comfort:
//            "Comfort"
//        case .business:
//            "Business"
//        case .minivan:
//            "Minivan"
//        case .truck:
//            "Truck"
//        case .evacuator:
//            "Evacuator"
//        }
//    }
//}

struct Vehicle: Identifiable, Equatable, Hashable {
    var id = UUID()
    var type: VehicleType
}

extension Vehicle {
    var title: String {
        switch type {
        case .econom:
            "Econom"
        case .comfort:
            "Comfort"
        case .business:
            "Business"
        case .minivan:
            "Minivan"
        case .truck:
            "Truck"
        case .evacuator:
            "Evacuator"
        }
    }
}

extension Vehicle {
    
    static let all: [Vehicle] = [Vehicle(type: .econom),
                                 Vehicle(type: .comfort),
                                 Vehicle(type: .business),
                                 Vehicle(type: .minivan),
                                 Vehicle(type: .truck),
                                 Vehicle(type: .evacuator)
    ]
}
