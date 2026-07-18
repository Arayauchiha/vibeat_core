//
//  OnboardingView.swift
//  Vibeeat
//
//  Created by Nupur on 18/07/26.
//

import SwiftUI

struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let caption: String
    let imageName: String
}

struct OnboardingView: View {
    @State private var showLogin: Bool = false
    @State private var currentPage = 0

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "No More “You Decide”",
            caption: "Invite anyone into a shared lobby and plan your next meal together.",
            imageName: "onboarding_lobby"
        ),
        OnboardingPage(
            title: "Everyone Has a Taste",
            caption: "Budget, cuisine, vibe, and travel distance, we consider every preference equally.",
            imageName: "onboarding_preferences"
        ),
        OnboardingPage(
            title: "One Place. Happy Everyone",
            caption: "We find restaurants that balance distance, budget, cuisine, and atmosphere—so everyone wins.",
            imageName: "onboarding_match"
        )
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button {
                showLogin = true
            } label: {
                Text("Get Started")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.accentColor, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 32)
            .padding(.top, 8)
            .navigationDestination(isPresented: $showLogin) {
                LoginView()
            }
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 28) {
            Spacer(minLength: 24)

            // Swap this for your final artwork when ready.
            // Image(page.imageName)
            //     .resizable()
            //     .scaledToFit()
            //     .frame(maxHeight: 320)
            //     .padding(.horizontal, 32)
            Image(systemName: "fork.knife.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 160, height: 160)
                .foregroundStyle(.tint)
                .accessibilityHidden(true)

            VStack(spacing: 12) {
                Text(page.title)
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.primary)

                Text(page.caption)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
            }
            .padding(.horizontal, 28)

            Spacer(minLength: 48)
        }
    }
}
