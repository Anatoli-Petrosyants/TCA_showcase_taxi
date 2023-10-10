//
//  MainView.swift
//  Showcase
//
//  Created by Anatoli Petrosyants on 26.04.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - MainView

struct MainView {
    let store: StoreOf<MainFeature>
}

// MARK: - Views

extension MainView: View {
    
    var body: some View {
        content
            .toolbar(.hidden, for: .tabBar)
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                Text("Main")
                
                SidebarView(
                    store: self.store.scope(
                        state: \.sidebar,
                        action: MainFeature.Action.sidebar
                    )
                )
                .ignoresSafeArea()
            }
        }
    }
}

#if DEBUG
// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(
            store:
                Store(initialState: MainFeature.State(), reducer: {
                    MainFeature()
                })
        )
    }
}
#endif
