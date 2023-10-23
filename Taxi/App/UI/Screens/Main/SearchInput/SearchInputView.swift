//
//  SearchInputView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 20.10.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - SearchInputView

struct SearchInputView {
    let store: StoreOf<SearchInputFeature>
    
    struct ViewState: Equatable {
        @BindingViewState var text: String
        var isEditing: Bool
        var isLoading: Bool
    }
}

// MARK: - Views

extension SearchInputView: View {
    
    var body: some View {
        content
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: \.view, send: { .view($0) }) { viewStore in
            HStack(spacing: 16) {
                TextField("Search address...", text: viewStore.$text)
                    .textFieldStyle(.plain)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .foregroundColor(Color.darkGray)
                    .font(.headline)
                    .tint(Color.darkGray)
                
                Spacer()
                
                if viewStore.isLoading {
                    ProgressView()
                        .tint(Color.darkGray)
                        .frame(width: 30, height: 30)
                } else {
                    if viewStore.isEditing {
                        Image(systemName: "xmark")
                            .frame(width: 30, height: 30)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewStore.send(.onClear)
                            }
                    } else {
                        Image(systemName: "magnifyingglass")
                            .renderingMode(.template)
                            .foregroundColor(Color.darkGray)
                            .frame(width: 30, height: 30)
                    }
                }
            }
            .padding([.leading, .trailing], 8)
            .padding([.top, .bottom], 6)
            .background(Color.gray03)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.darkGray, lineWidth: 1)
            )
        }
    }
}

// MARK: BindingViewStore

extension BindingViewStore<SearchInputFeature.State> {
    var view: SearchInputView.ViewState {
        SearchInputView.ViewState(text: self.$text, isEditing: self.isEditing, isLoading: self.isLoading)
    }
}