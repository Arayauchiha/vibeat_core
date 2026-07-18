//
//  SignUpView.swift
//  Vibeeat
//
//  Created by Nupur on 18/07/26.
//

import SwiftUI

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @FocusState private var focusedField: Field?

    private enum Field {
        case name, email, password, confirmPassword
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                brandHeader
                    .padding(.top, 32)
                    .padding(.bottom, 36)

                fieldsSection
                    .padding(.bottom, 24)

                Button {
                    focusedField = nil
                    // Wire up sign-up auth when ready
                } label: {
                    Text("Sign Up")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.white, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                Spacer(minLength: 40)

                HStack(spacing: 4) {
                    Text("Already have an account?")
                        .foregroundStyle(.white.opacity(0.55))

                    Button {
                        dismiss()
                    } label: {
                        Text("Log In")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                    }
                }
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .padding(.top, 24)
                .padding(.bottom, 16)
            }
            .padding(.horizontal, 28)
        }
        .scrollDismissesKeyboard(.interactively)
        .background(Color.black.ignoresSafeArea())
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white)
                }
            }
        }
        .preferredColorScheme(.dark)
    }

    private var brandHeader: some View {
        VStack(spacing: 14) {
            Image(systemName: "fork.knife.circle.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 72, height: 72)
                .foregroundStyle(.white)
                .accessibilityHidden(true)

            Text("Create Account")
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity)
    }

    private var fieldsSection: some View {
        VStack(spacing: 14) {
            authField(
                title: "Name",
                text: $name,
                field: .name,
                contentType: .name,
                keyboard: .default,
                isSecure: false,
                autocapitalize: .words
            )

            authField(
                title: "Email",
                text: $email,
                field: .email,
                contentType: .emailAddress,
                keyboard: .emailAddress,
                isSecure: false,
                autocapitalize: .never
            )

            authField(
                title: "Password",
                text: $password,
                field: .password,
                contentType: .newPassword,
                keyboard: .default,
                isSecure: true,
                autocapitalize: .never
            )

            authField(
                title: "Confirm Password",
                text: $confirmPassword,
                field: .confirmPassword,
                contentType: .newPassword,
                keyboard: .default,
                isSecure: true,
                autocapitalize: .never
            )
        }
    }

    private func authField(
        title: String,
        text: Binding<String>,
        field: Field,
        contentType: UITextContentType,
        keyboard: UIKeyboardType,
        isSecure: Bool,
        autocapitalize: TextInputAutocapitalization
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
                        .textInputAutocapitalization(autocapitalize)
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
}

#Preview {
    NavigationStack {
        SignUpView()
    }
}
