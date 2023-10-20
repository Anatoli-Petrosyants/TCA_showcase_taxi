//
//  WhereToView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 20.10.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - WhereToView

struct WhereToView {
    let store: StoreOf<WhereToFeature>
}

// MARK: - Views

extension WhereToView: View {
    
    var body: some View {
        content
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 20) {
                HStack {
                    Button("Cancel") {
                        viewStore.send(.view(.onCancelTap))
                    }
                    .foregroundColor(Color.darkGray)

                    Spacer()
                }
                
                SearchInputView(
                    store: self.store.scope(
                        state: \.input,
                        action: WhereToFeature.Action.input
                    )
                )
                
                ScrollView(showsIndicators: false) {
                    
                }
                
                Spacer()
            }
            .padding()
            .ignoresSafeArea()
            // .background(Color.darkGray)
        }
    }
}
