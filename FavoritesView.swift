//
//  FavoritesView.swift
//  MoodPlay MoodPlay MoodPlay
//
//  Created by Mahesh Rao on 7/22/25.
//

import SwiftUI

struct FavoritePlaylist: Identifiable {
    let id = UUID()
    let mood: String
    let title: String
    let musicPlatform: String
    let url: String
}

struct FavoritesView: View {
    @State private var selectedMood: Mood? = Mood(name: "Happy", emoji: "😀")

    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    @State private var favorites: [FavoritePlaylist] = [
        FavoritePlaylist(mood: "😀", title: "Happy Vibes", musicPlatform: "Spotify", url: "https://open.spotify.com/playlist/37i9dQZF1DX3rxVfibe1L0"),
        FavoritePlaylist(mood: "😀", title: "Good Mood Songs", musicPlatform: "Apple Music", url: "https://music.apple.com/us/playlist/feelin-good/pl.u-kv9lWlLsKqE"),
        FavoritePlaylist(mood: "😢", title: "Sad & Chill", musicPlatform: "Spotify", url: "https://open.spotify.com/playlist/37i9dQZF1DX7qK8ma5wgG1"),
        FavoritePlaylist(mood: "😢", title: "Crying in the Rain", musicPlatform: "YouTube Music", url: "https://music.youtube.com/playlist?list=PL4fGSI1pDJn7A_CZy4aM7hW7Rp9RMiQ49"),
        FavoritePlaylist(mood: "😌", title: "Evening Relax", musicPlatform: "Spotify", url: "https://open.spotify.com/playlist/37i9dQZF1DX4WYpdgoIcn6"),
        FavoritePlaylist(mood: "😌", title: "Lo-Fi Chill", musicPlatform: "Apple Music", url: "https://music.apple.com/us/playlist/lofi-chill/pl.6c709d98ba1c40b9acff82d6a0377ab6"),
        FavoritePlaylist(mood: "💘", title: "Romantic Vibes", musicPlatform: "Spotify", url: "https://open.spotify.com/playlist/37i9dQZF1DX50QitC6Oqtn"),
        FavoritePlaylist(mood: "💘", title: "Heartbeats", musicPlatform: "YouTube Music", url: "https://music.youtube.com/playlist?list=PLFgquLnL59amNzR8IhG4jGEGGPzC3fWtl"),
        FavoritePlaylist(mood: "😤", title: "Anger Management", musicPlatform: "Spotify", url: "https://open.spotify.com/playlist/37i9dQZF1DWX83CujKHHOn"),
        FavoritePlaylist(mood: "😤", title: "Hard Rock Hits", musicPlatform: "Apple Music", url: "https://music.apple.com/us/playlist/hard-rock-hits/pl.48b79f3e34594c58acb8a7710c0737b8"),
        FavoritePlaylist(mood: "⚡", title: "Motivation Boost", musicPlatform: "YouTube Music", url: "https://music.youtube.com/playlist?list=PLFgquLnL59alCl_2TQvOiD5Vgm1hCaGSI"),
        FavoritePlaylist(mood: "⚡", title: "Power Up!", musicPlatform: "Spotify", url: "https://open.spotify.com/playlist/37i9dQZF1DX76Wlfdnj7AP")
    ]

    private var selectedMoodGradient: LinearGradient {
        switch selectedMood?.name {
        case "Happy":
            return LinearGradient(colors: [.yellow.opacity(0.3), .orange.opacity(0.2)],
                                  startPoint: .top, endPoint: .bottom)
        case "Sad":
            return LinearGradient(colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                                  startPoint: .top, endPoint: .bottom)
        case "Chill":
            return LinearGradient(colors: [.mint.opacity(0.3), .cyan.opacity(0.2)],
                                  startPoint: .top, endPoint: .bottom)
        case "Love":
            return LinearGradient(colors: [.pink.opacity(0.3), .red.opacity(0.2)],
                                  startPoint: .top, endPoint: .bottom)
        case "Angry":
            return LinearGradient(colors: [.red.opacity(0.3), .orange.opacity(0.2)],
                                  startPoint: .top, endPoint: .bottom)
        case "Motivated":
            return LinearGradient(colors: [.orange.opacity(0.3), .yellow.opacity(0.2)],
                                  startPoint: .top, endPoint: .bottom)
        default:
            return LinearGradient(colors: [.white], startPoint: .top, endPoint: .bottom)
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                selectedMoodGradient
                    .animation(.easeInOut(duration: 0.5), value: selectedMood)
                    .edgesIgnoringSafeArea(.all)

                VStack(alignment: .leading, spacing: 16) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(moods, id: \.self) { mood in
                                Button(action: {
                                    withAnimation {
                                        selectedMood = mood
                                    }
                                }) {
                                    VStack {
                                        Text(mood.emoji)
                                            .font(.largeTitle)
                                        Text(mood.name)
                                            .font(.caption)
                                    }
                                    .padding()
                                    .background(mood == selectedMood ? Color.white.opacity(0.6) : Color.white.opacity(0.3))
                                    .scaleEffect(mood == selectedMood ? 1.1 : 1.0)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(mood == selectedMood ? Color.white : Color.clear, lineWidth: 2)
                                    )
                                    .cornerRadius(12)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }

                    Text("Your Favorites")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.horizontal)

                    ScrollView {
                        ForEach(favorites.filter { $0.mood == selectedMood?.emoji }) { playlist in
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(spacing: 12) {
                                    HStack(spacing: 8) {
                                        Text(playlist.mood)
                                            .font(.title2)
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(playlist.title)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            Text("on \(playlist.musicPlatform)")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    if let url = URL(string: playlist.url) {
                                        Link("Open in \(playlist.musicPlatform)", destination: url)
                                            .font(.caption)
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 6)
                                            .background(Color.blue.opacity(0.8))
                                            .foregroundColor(.white)
                                            .cornerRadius(20)
                                    }
                                }
                                .padding()
                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                                .shadow(radius: 5)
                                .padding(.horizontal)
                            }
                        }
                        if favorites.filter({ $0.mood == selectedMood?.emoji }).isEmpty {
                            Text("😕 No favorites found for this mood.")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                        }
                    }
                }
                .padding(.top)
            }
            .preferredColorScheme(isDarkMode ? .dark : .light)
            .navigationTitle("Favorites")
        }
    }
}

#Preview {
    FavoritesView()
}
