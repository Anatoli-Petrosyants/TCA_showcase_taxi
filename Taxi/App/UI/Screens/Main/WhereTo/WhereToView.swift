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
                
                VStack {
                    Group {
                        (/Loadable<[GoogleAutocompletePrediction]>.loaded).extract(from: viewStore.data).map { contacts in
                            List(contacts, id: \.self) { contact in
                                VStack(alignment: .leading) {
                                    Text("\(contact.placeID)")
                                        .font(.bodyBold)
                                    
                                    Text("\(contact.attributedFullText)")
                                        .font(.body)
                                }
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    // viewStore.send(.onContactTap(contact))
                                }
                            }
                            .environment(\.defaultMinListRowHeight, 44)
                            .listRowBackground(Color.clear)
                            .listStyle(.plain)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .ignoresSafeArea()
            // .background(Color.darkGray)
        }
    }
}
