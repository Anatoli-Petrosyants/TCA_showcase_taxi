//
//  QuickActionsHandler.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 13.11.23.
//

import Foundation
import UIKit

/// Enum defining the types of quick actions available.
enum QuickActionType: String {
    case lastAddress = "LastAddress"
    // Add new actions here in future
}

/// Enum defining the possible quick actions.
enum QuickAction: Equatable {
    case lastAddress

    /// Initialize a QuickAction based on the provided UIApplicationShortcutItem.
    ///
    /// - Parameter shortcutItem: The shortcut item to create the QuickAction from.
    init?(shortcutItem: UIApplicationShortcutItem) {
        guard let type = QuickActionType(rawValue: shortcutItem.type) else {
            return nil
        }

        switch type {
        case .lastAddress:
            self = .lastAddress
        }
    }
}

/// Singleton class responsible for handling quick actions.
class QuickActionsHandler: ObservableObject {
    /// Shared instance of QuickActionsHandler.
    static let shared = QuickActionsHandler()

    /// Property of the selected quick action.
    var action: QuickAction?
}
