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
                ZStack(alignment: .topLeading) {
                    Color.clear
                    
                    MapView(
                        store: self.store.scope(
                            state: \.map,
                            action: MainFeature.Action.map
                        )
                    )
                    .ignoresSafeArea()                    
//                        HStack {
//                            Button {
//                                viewStore.send(.view(.onMenuTap))
//                            } label: {
//                                Image(systemName: "line.3.horizontal")
//                                    .tint(Color.white)
//                            }
//                            .padding(8)
//                            .background(Color.primaryBlack)
//                            .clipShape(RoundedRectangle(cornerRadius: 3))
//
//                            Spacer()
//                        }
//                        .padding(8)
                }
                
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

