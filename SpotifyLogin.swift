//
//  SpotifyLogin.swift
//  MoodPlay MoodPlay MoodPlay
//
//  Created by Mahesh Rao on 8/2/25.
//

import SwiftUI

struct SpotifyLoginView: View {
    var onContinue: () -> Void
    var onSkip: () -> Void

    @State private var showConfirmation = false

    var body: some View {
        VStack(spacing: 30) {
            Spacer()

            VStack(spacing: 12) {
                Text("Connect with Spotify")
                    .font(.title)
                    .fontWeight(.bold)

                Text("Log in with Spotify for a better experience: get mood-based music suggestions, track your vibe, and more.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Text("Highly recommended for personalized songs!")
                    .font(.footnote)
                    .foregroundColor(.green)
                    .transition(.opacity)
            }

            Button(action: {
                showConfirmation = true
            }) {
                HStack {
                    Image("spotify_logo")
                        .resizable()
                        .frame(width: 24, height: 24)
                    Text("Continue with Spotify")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .padding()
                .background(Color.green)
                .cornerRadius(12)
            }
            .padding(.horizontal, 30)

            Button(action: {
                onSkip()
            }) {
                Text("Skip for now")
                    .foregroundColor(.gray)
            }

            Spacer()
        }
        .padding()
        .fullScreenCover(isPresented: $showConfirmation) {
            VStack(spacing: 20) {
                Spacer()

                Text("Are you sure?")
                    .font(.title)
                    .fontWeight(.semibold)

                Text("Connecting to Spotify helps you get better music suggestions and sync your vibe, but it's optional.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 30)

                Button("Continue with Spotify") {
                    SpotifyAuthManager().startLogin()
                    onContinue()
                }
                .frame(maxWidth: .infinity, minHeight: 50)
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(12)
                .padding(.horizontal, 30)

                Button("Go Back") {
                    showConfirmation = false
                }
                .foregroundColor(.gray)

                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SpotifyLoginView(
        onContinue: {},
        onSkip: {}
    )
}
