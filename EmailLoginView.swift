//
//  EmailLoginView.swift
//  MoodPlay MoodPlay MoodPlay
//
//  Created by Mahesh Rao on 7/23/25.
//

import SwiftUI
import FirebaseAuth

struct EmailLoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var errorMessage: String?
    @State private var isLogin = true // Toggle between login and sign-up

    var body: some View {
        VStack(spacing: 20) {
            Text(isLogin ? "Login" : "Sign Up")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("Email", text: $email)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            SecureField("Password", text: $password)
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: handleAuth) {
                Text(isLogin ? "Login" : "Sign Up")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }

            Button(action: {
                isLogin.toggle()
                errorMessage = nil
            }) {
                Text(isLogin ? "Don't have an account? Sign up" : "Already have an account? Login")
                    .font(.footnote)
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }

    func handleAuth() {
        errorMessage = nil

        if isLogin {
            // Login
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    // Success - move to app
                }
            }
        } else {
            // Sign Up
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    // Success - move to app
                }
            }
        }
    }
}
