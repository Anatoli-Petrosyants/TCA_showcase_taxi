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
        content.onAppear { self.store.send(.onViewAppear) }
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in            
            VStack(spacing: 0) {
                Text("Set your pickup spot")
                    .font(.subheadlineBold)
                    .foregroundColor(Color.white07)
                    .padding()
                
                Divider()
                    .frame(height: 2)
                    .overlay(.gray)
                
                Spacer()
                
                Button("Confirm pickup", action: {
                    
                })
                .font(.headlineBold)
                .frame(minWidth: 200, maxWidth: .infinity, minHeight: 52)
                .foregroundColor(Color.black)
                .background(Color.white07)
                .clipShape(Capsule())
                .padding()
                .padding(.bottom, 10)
            }
            .frame(maxWidth: .infinity)
            .frame(maxHeight: 200)
            .background(.black)
            .transition(.opacity.combined(with: .move(edge: .bottom)))
        }
    }
}

struct PickupSpotBottomSheetView<Content: View>: View {
    var content: () -> Content

    @Binding var moving: Bool

    var body: some View {
        ZStack(alignment: .bottom) {
            if !moving {
                content()
                    .frame(maxWidth: .infinity)
                    .frame(maxHeight: 200)
                    .background(.black)
                    .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .animation(.easeInOut(duration: 0.2), value: !moving)
    }
}
