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
        content.onAppear { self.store.send(.onViewAppear) }
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            ZStack {
                Color.darkGray
                
                Text("WhereTo Feature")
                    .font(.title1Bold)
                    .foregroundColor(Color.white)
                    .padding()
            }
            .ignoresSafeArea()
        }
    }
}
