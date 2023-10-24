//
//  HelpView.swift
//  Showcase
//
//  Created by Anatoli Petrosyants on 10.04.23.
//

import SwiftUI
import ComposableArchitecture

// MARK: - HelpView

struct OnboardingView {
    let store: StoreOf<OnboardingFeature>
    
    struct ViewState: Equatable {
        var items: [Onboarding]
        var selectedTab: Onboarding.Tab
        var showGetStarted: Bool
    }
}

// MARK: - Views

extension OnboardingView: View {

    var body: some View {
        content
    }

    @ViewBuilder private var content: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                TabView(selection: viewStore.binding(get: \.selectedTab,
                                                     send: OnboardingFeature.Action.onTabChanged) ) {
                    ForEach(viewStore.items) { viewData in
                        OnboardingPageView(data: viewData)
                            .tag(viewData.tab)
                            .padding(.bottom, 50)
                    }
                }
                .tabViewStyle(PageTabViewStyle())
                .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                
                Button(Localization.Help.getStarted) {
                    viewStore.send(.onGetStartedTapped)
                }
                .buttonStyle(.cta)
                .padding(.bottom)
                .isHidden(!viewStore.showGetStarted)
            }
            .padding()
            .background(Color.black.ignoresSafeArea())
        }
    }
}

// MARK: HelpPageView

struct OnboardingPageView: View {
    
    var data: Onboarding

    @State private var isAnimating: Bool = false
    @State private var playLottie = false

    var body: some View {
        VStack(spacing: 0) {
            LottieViewRepresentable(name: data.lottie, loopMode: .autoReverse, play: $playLottie)

            Spacer()

            Text(data.title)
                .font(.headlineBold)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)

            Text(data.description)
                .font(.subheadline)
                .foregroundColor(Color.white)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
            
            Spacer()
        }
        .onAppear(perform: {
            playLottie = true
            isAnimating = false
            withAnimation(.easeOut(duration: 0.5)) {
                self.isAnimating = true
            }
        })
    }
}
