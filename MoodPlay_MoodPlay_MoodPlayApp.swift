//
//  MoodPlay_MoodPlay_MoodPlayApp.swift
//  MoodPlay MoodPlay MoodPlay
//
//  Created by Mahesh Rao on 7/21/25.
//
import SwiftUI
import Firebase
import GoogleSignIn

@main
struct MoodPlayApp: App {
    @AppStorage("isUsernameSet") private var isUsernameSet: Bool = false
    @AppStorage("loginSuccessful") private var loginSuccessful: Bool = false
    @AppStorage("spotifyConnected") private var spotifyConnected: Bool = false
    @AppStorage("loggedInAsGuest") private var loggedInAsGuest: Bool = false

    var body: some Scene {
        WindowGroup {
            NavigationView {
                if loginSuccessful || loggedInAsGuest {
                    if !isUsernameSet {
                        EnterNameView()
                    } else if !spotifyConnected {
                        SpotifyLoginView(
                            onContinue: {
                                spotifyConnected = true
                            },
                            onSkip: {
                                spotifyConnected = true
                            }
                        )
                    } else {
                        ContentView()
                    }
                } else {
                    LoginView()
                }
            }
            .onAppear {
                FirebaseApp.configure()

                // Restore previous Google session if available
                if GIDSignIn.sharedInstance.hasPreviousSignIn() {
                    GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
                        if let _ = user {
                            loginSuccessful = true
                            loggedInAsGuest = false
                        } else {
                            print("⚠️ Could not restore session:", error?.localizedDescription ?? "Unknown error")
                        }
                    }
                }

                print("🧪 loginSuccessful =", loginSuccessful)
                print("🧪 isUsernameSet =", isUsernameSet)
                print("🧪 spotifyConnected =", spotifyConnected)
                print("🧪 loggedInAsGuest =", loggedInAsGuest)
            }
        }
    }
}
