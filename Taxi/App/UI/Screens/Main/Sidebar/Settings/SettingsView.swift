//
//  SettingsView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 10.10.23.
//


import SwiftUI
import ComposableArchitecture

// MARK: - SettingsView

struct SettingsView {
    let store: StoreOf<SettingsFeature>
}

// MARK: - Views

extension SettingsView: View {
    
    var body: some View {
        content.onAppear { self.store.send(.onViewAppear) }
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            Text("Settings")
        }
    }
}
