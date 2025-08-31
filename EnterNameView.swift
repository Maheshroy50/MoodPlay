//
//  EnterNameView.swift
//  MoodPlay MoodPlay MoodPlay
//
//  Created by Mahesh Rao on 7/22/25.
//

import SwiftUI

struct EnterNameView: View {
    @State private var username: String = ""
    @AppStorage("isUsernameSet") private var isUsernameSet: Bool = false
    @AppStorage("spotifyConnected") private var spotifyConnected: Bool = false
    @State private var navigateToApp: Bool = false

    var body: some View {
        ZStack {
            WelcomeBackgroundView()
                .ignoresSafeArea()

            VStack(spacing: 20) {
                Spacer()

                VStack(spacing: 12) {
                    Text("Welcome to")
                        .font(.title)
                        .foregroundColor(.black)
                        .opacity(0.8)

                    Text("MoodPlay")
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.blue)
                        .shadow(radius: 4)

                    Text("Please enter your name to continue")
                        .font(.subheadline)
                        .foregroundColor(.black)
                        .opacity(0.9)
                        .multilineTextAlignment(.center)
                        .padding(.top, 4)
                }

                VStack(spacing: 20) {
                    TextField("Your Name", text: $username)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)

                    Button(action: {
                        if !username.isEmpty {
                            UserDefaults.standard.set(username, forKey: "username")
                            isUsernameSet = true
                            spotifyConnected = false
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Continue")
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Image(systemName: "arrow.right")
                                .foregroundColor(.white)
                            Spacer()
                        }
                        .padding()
                        .background(username.isEmpty ? Color.gray : Color.blue)
                        .cornerRadius(12)
                        .shadow(color: Color.black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    .disabled(username.isEmpty)
                }

                Spacer()
            }
            .padding()
        }
    }
}
