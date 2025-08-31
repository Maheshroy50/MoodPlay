//  Logview.swift
//  MoodPlay MoodPlay MoodPlay
//
//  Created by Mahesh Rao on 7/22/25.
//

import SwiftUI
import AuthenticationServices
import GoogleSignIn // Keep this for GIDSignIn.sharedInstance.presentingViewController
import GoogleSignInSwift // Important for GoogleSignInButton
import FirebaseAuth
// Ensure EmailLoginView is imported or defined in your project

struct LoginView: View {
    @AppStorage("loginSuccessful") private var loginSuccessful: Bool = false
    @State private var animate = false
    @AppStorage("isUsernameSet") private var isUsernameSet: Bool = false
    @AppStorage("loggedInAsGuest") private var loggedInAsGuest: Bool = false
    @AppStorage("spotifyConnected") private var spotifyConnected: Bool = false

    var body: some View {
        ZStack {
            WelcomeBackgroundView()
                .ignoresSafeArea()

            ZStack {
                VStack(spacing: 30) {
                    Spacer()

                    VStack(spacing: 10) {
                        Text("MoodPlay")
                            .font(.system(size: 40, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

                        Text("Music that matches your mood.")
                            .font(.system(size: 18, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.85))
                    }
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : -20)
                    .animation(.easeOut(duration: 1), value: animate)

                    Spacer()

                    VStack(spacing: 20) {
                        // MARK: - Google Sign-In Button (FIXED)
                        GoogleSignInButton {
                            // Action to perform when the button is tapped
                            loggedInAsGuest = false
                            signInWithGoogle()
                        }
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

                        // Removed Spotify button as per instructions

                        // MARK: - Sign in with Apple Button (already correct)
                        SignInWithAppleButton(
                            .signIn,
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                switch result {
                                case .success(let authResults):
                                    print("Apple Sign-In Success: \(authResults)")
                                    loginSuccessful = true
                                case .failure(let error):
                                    print("Apple Sign-In Failed: \(error.localizedDescription)")
                                }
                            }
                        )
                        .signInWithAppleButtonStyle(.black)
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .cornerRadius(10) // Changed from 10 to 12 to match other buttons
                        .padding(.top, 5) // Kept original padding
                        .overlay(
                            RoundedRectangle(cornerRadius: 12) // Matched cornerRadius
                                .fill(Color.white.opacity(0.15))
                        )
                        .background(Color.white)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)

                        Button(action: {
                            print("Guest button tapped")
                            loggedInAsGuest = true
                            isUsernameSet = false
                            loginSuccessful = true
                        }) {
                            Text("Continue as Guest")
                                .font(.subheadline)
                        }
                        .modifier(AuthButtonStyle(background: .white, textColor: .blue))
                        .frame(maxWidth: .infinity, minHeight: 50)
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        .padding(.top, 5)
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                    .cornerRadius(30)
                    .shadow(radius: 10)
                    .fixedSize(horizontal: false, vertical: true)
                    .animation(nil)

                    Spacer()
                }
                .padding(.horizontal, 24)
                .padding(.top, 60)
                .onAppear {
                    animate = true
                }
                .navigationTitle("")
                .navigationBarHidden(true)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
    }

    private func signInWithGoogle() {
        guard let rootVC = UIApplication.shared.windows.first?.rootViewController else {
            print("❌ Could not get root view controller.")
            return
        }

        GoogleSignInHelper.shared.signIn(presenting: rootVC) { result in
            switch result {
            case .success(let authResult):
                print("✅ Logged in as \(authResult.user.email ?? "unknown email")")
                loggedInAsGuest = false
                loginSuccessful = true
            case .failure(let error):
                print("❌ Google Sign-In error:", error.localizedDescription)
            }
        }
    }
}

struct AuthButtonStyle: ViewModifier {
    var background: Color
    var textColor: Color = .black
    var padding: CGFloat = 12
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .frame(maxWidth: .infinity)
            .background(background)
            .foregroundColor(textColor)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    LoginView()
}

extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex.replacingOccurrences(of: "#", with: ""))
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)

        let r = Double((rgb >> 16) & 0xFF) / 255
        let g = Double((rgb >> 8) & 0xFF) / 255
        let b = Double(rgb & 0xFF) / 255

        self.init(red: r, green: g, blue: b)
    }
}
