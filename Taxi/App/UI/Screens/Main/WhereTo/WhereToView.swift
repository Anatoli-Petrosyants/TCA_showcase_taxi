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
    
    private var text: AttributedString {
        let string = "Attributed String"

        let attributes: [NSAttributedString.Key : Any] = [
            NSAttributedString.Key.foregroundColor: UIColor.systemPink,
            NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 40),
            NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        // 1
        let nsAttributedString = NSAttributedString(string: string, attributes: attributes)

        // 2
        let attributedString = AttributedString(nsAttributedString)

        return attributedString
    }
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
                        (/Loadable<[GoogleAutocompletePrediction]>.loaded).extract(from: viewStore.data).map { predictions in
                            List(predictions, id: \.self) { prediction in
                                VStack(alignment: .leading) {
//                                    Text("\(contact.placeID)")
//                                        .font(.bodyBold)
                                    
                                    Text(prediction.text)
                                        .font(.subheadline)
                                        .foregroundColor(Color.black08)
                                }
                                .padding([.top, .bottom], 4)
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
