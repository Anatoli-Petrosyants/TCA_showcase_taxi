//
//  MapView.swift
//  Taxi
//
//  Created by Anatoli Petrosyants on 10.10.23.
//

import SwiftUI
import ComposableArchitecture
import GoogleMaps

// MARK: - MapView

struct MapView {
    let store: StoreOf<MapFeature>
    
    @State private var moving: Bool = false
}

// MARK: - Views

extension MapView: View {
    
    var body: some View {
        content
            .onLoad { self.store.send(.view(.onViewLoad)) }
    }
    
    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }, send: { .view($0) }) { viewStore in
            ZStack(alignment: .bottomTrailing) {
                ZStack(alignment: .top) {
                    GoogleMapViewRepresentable(
                        userLocation: viewStore.userLocation,
                        mapViewIdleAtPosition: { position in
                            viewStore.send(.onMapViewIdleAtPosition(position))
                            moving = false
                        },
                        mapViewWillMove: { gesture in
                            moving = true
                        }
                    )

                    ChooseAddressPinView(moving: $moving)
                            .frame(width: 100, height: 100)
                            // .padding(.top, (UIScreen.main.bounds.size.height - cameraTopPadding) / 2 - 92)
                            .padding(.top, (UIScreen.main.bounds.size.height) / 2 - 92)
                }

                HStack(alignment: .bottom) {
                    Button {
                        viewStore.send(.onWhereToButtonTap)
                    } label: {
                        Text("Where To?")
                            .foregroundColor(Color.white)
                            .font(.system(size: 16))
                            .padding(10)
                            .background(Color.darkGray)
                            .clipShape(RoundedRectangle(cornerRadius: 3))
                            .shadow(color: Color.black01, radius: 4)
                            .contentShape(Rectangle())
                    }

                    Spacer()
                    
                    CurrentLocationButton(didTap: {
                        viewStore.send(.onLocationButtonTap)
                    })
                }
                .padding([.leading, .trailing], 8)
                .offset(y: -110)
                .opacity(moving ? 0 : 1.0)
                .animation(.linear(duration: 0.1), value: moving)

                PickupSpotBottomSheetView(content: {
                    PickupSpotView(
                        store: self.store.scope(
                            state: \.pickupSpot,
                            action: MapFeature.Action.pickupSpot
                        )
                    )
                }, moving: $moving)
            }
            .ignoresSafeArea()
            .sheet(
                store: self.store.scope(state: \.$whereTo, action: { .whereTo($0) }),
                content: WhereToView.init(store:)
            )
        }
    }
}
