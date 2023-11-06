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
                    .foregroundColor(Color.white)

                    Spacer()
                }
                
                SearchInputView(
                    store: self.store.scope(
                        state: \.input,
                        action: WhereToFeature.Action.input
                    )
                )                
                
                VStack {
                    Group {
                        (/Loadable<[GooglePlacesClient.AutocompletePredictionResponse]>.loaded).extract(from: viewStore.data).map { predictions in
                            List(predictions, id: \.self) { prediction in
                                VStack(alignment: .leading) {
                                    Text(prediction.text)
                                        .font(.subheadline)
                                        .foregroundColor(Color.white)
                                }
                                .padding([.top, .bottom], 4)
                                .contentShape(Rectangle())
                                .listRowBackground(Color.clear)
                                .listRowSeparatorTint(Color.white05)
                                .onTapGesture {
                                    viewStore.send(.view(.onPredictionTap(prediction)))
                                }
                            }
                            .environment(\.defaultMinListRowHeight, 44)
                            .listStyle(.plain)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .ignoresSafeArea()
            .background(Color.black)
        }
    }
}
