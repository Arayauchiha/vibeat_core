//
//  LoginView.swift
//  Vibeeat
//
//  Created by Nupur on 18/07/26.
//

import AuthenticationServices
import SwiftUI

struct LoginView: View {
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false

    @State private var isSubmitting = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            brandHeader
                .padding(.bottom, 56)

            SignInWithAppleButton(.signIn) { request in
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                Task { await handleAppleLogin(result) }
            }
            .signInWithAppleButtonStyle(.black)
            .frame(height: 52)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
            )
            .disabled(isSubmitting)
            .overlay {
                if isSubmitting {
                    ProgressView()
                        .tint(.white)
                }
            }

            Spacer()
            Spacer()
        }
        .padding(.horizontal, 28)
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
        .alert(
            "Login Failed",
            isPresented: Binding(
                get: { errorMessage != nil },
                set: { isPresented in
                    if !isPresented { errorMessage = nil }
                }
            )
        ) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Something went wrong. Please try again.")
        }
    }

    // MARK: - Brand

    private var brandHeader: some View {
        VStack(spacing: 14) {
            Image(systemName: "fork.knife.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundStyle(.white)
                .accessibilityHidden(true)

            Text("Vibeeat")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Auth actions

    private func handleAppleLogin(_ result: Result<ASAuthorization, any Error>) async {
        switch result {
        case let .success(authorization):
            guard
                let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                let tokenData = credential.identityToken,
                let idToken = String(data: tokenData, encoding: .utf8)
            else {
                errorMessage = "Couldn't read your Apple ID credentials. Please try again."
                return
            }

            isSubmitting = true
            defer { isSubmitting = false }

            do {
                try await VibeatAPIClient.shared.login(idToken: idToken)
                isLoggedIn = true
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
            }

        case let .failure(error):
            // Apple returns this when the user cancels the sheet — no need to surface it as an error.
            let nsError = error as NSError
            if nsError.domain == ASAuthorizationError.errorDomain,
               nsError.code == ASAuthorizationError.canceled.rawValue {
                return
            }

            errorMessage = error.localizedDescription
        }
    }
}

#Preview {
    LoginView()
}
