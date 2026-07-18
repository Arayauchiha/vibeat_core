//
//  LoginView.swift
//  Vibeeat
//
//  Created by Nupur on 18/07/26.
//

import AuthenticationServices
import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    private enum Field {
        case email, password
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    brandHeader
                        .padding(.top, 48)
                        .padding(.bottom, 40)

                    credentialsSection
                        .padding(.bottom, 20)

                    submitButton
                        .padding(.bottom, 28)

                    continueDivider
                        .padding(.bottom, 28)

                    SignInWithAppleButton(.signIn) { request in
                        request.requestedScopes = [.fullName, .email]
                    } onCompletion: { _ in
                        // Wire up Apple auth when ready
                    }
                    .signInWithAppleButtonStyle(.black)
                    .frame(height: 52)
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    )

                    Spacer(minLength: 40)

                    accountSwitchRow
                        .padding(.top, 24)
                        .padding(.bottom, 16)
                }
                .padding(.horizontal, 28)
            }
            .scrollDismissesKeyboard(.interactively)
            .background(Color.black.ignoresSafeArea())
            .navigationDestination(for: AuthRoute.self) { route in
                switch route {
                case .signUp:
                    SignUpView()
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    // MARK: - Brand

    private var brandHeader: some View {
        VStack(spacing: 14) {
            // Swap for your logo asset when ready:
            // Image("app_logo")
            //     .resizable()
            //     .scaledToFit()
            //     .frame(width: 72, height: 72)
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

    // MARK: - Fields

    private var credentialsSection: some View {
        VStack(spacing: 14) {
            authField(
                title: "Email",
                text: $email,
                field: .email,
                contentType: .emailAddress,
                keyboard: .emailAddress,
                isSecure: false
            )

            authField(
                title: "Password",
                text: $password,
                field: .password,
                contentType: .password,
                keyboard: .default,
                isSecure: true
            )
        }
    }

    private func authField(
        title: String,
        text: Binding<String>,
        field: Field,
        contentType: UITextContentType,
        keyboard: UIKeyboardType,
        isSecure: Bool
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.7))

            Group {
                if isSecure {
                    SecureField(title, text: text)
                } else {
                    TextField(title, text: text)
                        .textInputAutocapitalization(.never)
                        .keyboardType(keyboard)
                        .autocorrectionDisabled()
                }
            }
            .textContentType(contentType)
            .focused($focusedField, equals: field)
            .foregroundStyle(.white)
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .stroke(Color.white.opacity(focusedField == field ? 0.35 : 0.12), lineWidth: 1)
            )
        }
    }

    // MARK: - Submit

    private var submitButton: some View {
        Button {
            focusedField = nil
            // Wire up email/password auth when ready
        } label: {
            Text("Log In")
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
    }

    // MARK: - Divider

    private var continueDivider: some View {
        HStack(spacing: 14) {
            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 1)

            Text("or Continue with")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.55))
                .layoutPriority(1)

            Rectangle()
                .fill(Color.white.opacity(0.2))
                .frame(height: 1)
        }
    }

    // MARK: - Account switch

    private var accountSwitchRow: some View {
        HStack(spacing: 4) {
            Text("Don't have an account?")
                .foregroundStyle(.white.opacity(0.55))

            NavigationLink("Sign Up", value: AuthRoute.signUp)
                .fontWeight(.semibold)
                .foregroundStyle(.white)
        }
        .font(.subheadline)
        .frame(maxWidth: .infinity)
    }
    @Environment(\.dismiss) private var dismiss

    private func submitEmailLogin() async throws {
    }

    private func handleAppleLogin(_ result: Result<ASAuthorization, any Error>) async {
        switch result {
        case let .success(auth):
//            do {
//                guard let credential = auth.credential as? ASAuthorizationAppleIDCredential,
//                      let tokenData = credential.identityToken,
//                      let tokenString = String(data: tokenData, encoding: .utf8) else {
//                    throw Error()
//                }

// TODO:


        case let .failure(error):
//            TODO
        }
    }
    
}

private enum AuthRoute: Hashable {
    case signUp
}

#Preview {
    LoginView()
}
