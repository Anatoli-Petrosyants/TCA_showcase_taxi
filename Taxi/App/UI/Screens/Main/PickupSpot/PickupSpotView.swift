//
//  PickupSpotView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 18.10.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - PickupSpotView

struct PickupSpotView {
    let store: StoreOf<PickupSpotFeature>
}

// MARK: - Views

extension PickupSpotView: View {
    
    var body: some View {
        content
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack(spacing: 0) {
                HStack {
                    Text(viewStore.address)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                        .font(.subheadlineBold)
                        .foregroundColor(Color.white)

                    Spacer()
                    
                    Button {
                        viewStore.send(.view(.onGoButtonTap))
                    } label: {
                        Text("GO")
                            .font(.headlineBold)
                            .foregroundColor(Color.black)
                            .padding()
                    }
                    .background(Color.white)
                    .clipShape(Circle())
                }
                .padding()
                
                Spacer()
                
//                VStack {
//                    Spacer()
//                    Text("Set your pickup spot")
//                        .font(.subheadline)
//                        .foregroundColor(Color.white08)
//                    Spacer()
//                    Divider()
//                        .frame(height: 2)
//                        .overlay(Color.white01)
//                }
//                .frame(maxWidth: .infinity, maxHeight: 50)
//                // .padding([.leading, .trailing], 8)
//
//                VStack {
//                    HStack {
//                        Text(viewStore.address)
//                            .multilineTextAlignment(.leading)
//                            .lineLimit(2)
//                            .font(.subheadlineBold)
//                            .foregroundColor(Color.white08)
//
//                        Spacer()
//
//                        Button {
//                            // #dev send search action
//                        } label: {
//                            Text("GO")
//                                .font(.headlineBold)
//                                .foregroundColor(Color.black)
//                                .padding()
//                        }
//                        .background(Color.white08)
//                        .clipShape(Circle())
//
//                        /*
//                        Button {
//                            // #dev send search action
//                        } label: {
//                            Text("Search")
//                                .font(.subheadline)
//                                .foregroundColor(Color.white)
//                                .padding(8)
//                        }
//                        .background(Color.white03)
//                        .clipShape(Capsule())
//                        */
//                    }
//                    .padding([.leading, .trailing], 16)
//                }
//                .frame(maxWidth: .infinity, maxHeight: 80)
//
//                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: 120)
            .padding(.top, 4)
            .background(Color.black)
        }
    }
}

struct PickupSpotBottomSheetView<Content: View>: View {
    var content: () -> Content

    @Binding var moving: Bool

    var body: some View {
        ZStack(alignment: .top) {
            if !moving {
                content()
                    // .cornerRadius(8, corners: .topLeft)
                    // .cornerRadius(8, corners: .topRight)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: !moving)
    }
}
