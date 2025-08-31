//
//  ContentView.swift
//  MoodPlay MoodPlay MoodPlay
//
//  Created by Mahesh Rao on 7/21/25.
//

import SwiftUI


struct Mood: Hashable {
    let name: String
    let emoji: String
}

let moods: [Mood] = [
    Mood(name: "Happy", emoji: "😀"),
    Mood(name: "Sad", emoji: "😢"),
    Mood(name: "Chill", emoji: "😌"),
    Mood(name: "Love", emoji: "💘"),
    Mood(name: "Angry", emoji: "😤"),
    Mood(name: "Motivated", emoji: "⚡")
]

struct Playlist {
    let title: String
    let url: String
}

let moodPlaylists: [Mood: [Playlist]] = [
    Mood(name: "Happy", emoji: "😀"): [
        Playlist(title: "Have a Great Day!", url: "https://open.spotify.com/playlist/37i9dQZF1DX3rxVfibe1L0")
    ],
    Mood(name: "Sad", emoji: "😢"): [
        Playlist(title: "Life Sucks", url: "https://open.spotify.com/playlist/37i9dQZF1DX7qK8ma5wgG1")
    ],
    Mood(name: "Chill", emoji: "😌"): [
        Playlist(title: "Chill Hits", url: "https://open.spotify.com/playlist/37i9dQZF1DX4WYpdgoIcn6")
    ],
    Mood(name: "Love", emoji: "💘"): [
        Playlist(title: "Love Pop", url: "https://open.spotify.com/playlist/37i9dQZF1DX50QitC6Oqtn")
    ],
    Mood(name: "Angry", emoji: "😤"): [
        Playlist(title: "Rock Hard", url: "https://open.spotify.com/playlist/37i9dQZF1DWX83CujKHHOn")
    ],
    Mood(name: "Motivated", emoji: "⚡"): [
        Playlist(title: "Beast Mode", url: "https://open.spotify.com/playlist/37i9dQZF1DX76Wlfdnj7AP")
    ]
]


struct FavoriteItem: Identifiable, Codable {
    var id = UUID()
    var mood: String
    var title: String
    var url: String
}

class FavoritesManager: ObservableObject {
    @Published var favorites: [FavoriteItem] = [] {
        didSet {
            saveFavorites()
        }
    }

    private let key = "favorites"

    init() {
        loadFavorites()
    }

    func addFavorite(_ item: FavoriteItem) {
        if !favorites.contains(where: { $0.title == item.title && $0.url == item.url }) {
            favorites.append(item)
        }
    }

    func loadFavorites() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([FavoriteItem].self, from: data) {
            favorites = decoded
        }
    }

    func saveFavorites() {
        if let encoded = try? JSONEncoder().encode(favorites) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}

struct ContentView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var selectedMood: Mood? = nil
    @State private var playlistTitle: String = ""
    @State private var playlistURL: String = ""
    @StateObject private var favoritesManager = FavoritesManager()
    @State private var fetchedTracks: [SpotifyTrack] = []

    @State private var showSettings = false
    @AppStorage("username") private var username: String = "Mahesh"
    @AppStorage("musicService") private var selectedService: String = "Spotify"

    // Added AppStorage properties for logout
    @AppStorage("loginSuccessful") private var loginSuccessful: Bool = false
    @AppStorage("isUsernameSet") private var isUsernameSet: Bool = false
    @AppStorage("spotifyConnected") private var spotifyConnected: Bool = false
    @AppStorage("loggedInAsGuest") private var loggedInAsGuest: Bool = false

    @Namespace private var animationNamespace
    @State private var waving = false
    
    var selectedMoodGradient: LinearGradient {
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

    private func handleMoodSelection(_ mood: Mood) {
        withAnimation(.easeInOut(duration: 0.5)) {
            selectedMood = mood
        }

        let playlist = moodPlaylists[mood]?.randomElement()
        playlistTitle = playlist?.title ?? "No playlist"
        playlistURL = playlist?.url ?? ""

        let moodName = mood.name

        // ✅ Firestore mood logging
        MoodLogger.shared.logMood(moodName) { error in
            if let error = error {
                print("Error logging mood to Firestore:", error.localizedDescription)
            } else {
                print("Mood '\(moodName)' logged successfully.")
            }
        }

        SpotifyAuthManager.shared.getAccessToken { token in
            guard let token = token else {
                print("Failed to get access token")
                return
            }

            SpotifyAPIManager.shared.searchTracks(mood: moodName, accessToken: token, completion: { tracks in
                DispatchQueue.main.async {
                    self.fetchedTracks = tracks
                }
            })
        }
    }

    var body: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 20) {
                        // Removed Ani() call from inside ScrollView
                        Text("MoodPlay")
                            .font(.system(size: 64, weight: .black, design: .rounded))
                            .foregroundColor(.blue)
                            .multilineTextAlignment(.center)
                            .frame(maxWidth: .infinity)
                            .padding(.top, 10)
            // Enhanced Greeting card - Option 3
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 20)
                    .fill(LinearGradient(colors: [.purple.opacity(0.2), .blue.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(height: 100)

                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 6) {
                        Text("Hi \(username),")
                            .font(.system(size: 26, weight: .heavy, design: .rounded))
                            .foregroundColor(.primary)
                        Text("👋")
                            .font(.system(size: 26))
                            .rotationEffect(.degrees(waving ? 15 : -15))
                            .animation(.easeInOut(duration: 0.4).repeatCount(8, autoreverses: true), value: waving)
                    }
                    .onAppear {
                        waving = true
                    }
                    Text("Pick your mood for today")
                        .font(.headline)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 24)
            }
            .padding(.horizontal)

            // Modern Mood Grid
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())],
                spacing: 20
            ) {
                ForEach(moods, id: \.self) { mood in
                    Button(action: {
                        handleMoodSelection(mood)
                    }) {
                        VStack(spacing: 2) {
                            Text(mood.emoji)
                                .font(.system(size: 42))
                            Text(mood.name)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.primary)
                        }
                        .frame(width: 90, height: 90)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(.ultraThinMaterial)
                                .shadow(color: .black.opacity(0.05), radius: 2, x: 1, y: 2)
                        )
                        // Removed blue border overlay
                        .scaleEffect(selectedMood == mood ? 1.06 : 1.0)
                        .animation(.easeInOut(duration: 0.25), value: selectedMood)
                        .contentShape(RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.top, 10)
            .padding(.horizontal)

            Spacer()
            
            if !fetchedTracks.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Suggested Songs")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.bottom, 4)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(fetchedTracks) { track in
                                trackCardView(for: track)
                                    .padding(8)
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(12)
                                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 2, y: 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }

            if !playlistTitle.isEmpty {
                VStack(alignment: .leading, spacing: 20) {
                    Text("Your Mood Playlist:")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.bottom, 8)
                        .padding(.top, 4)

                    Text(playlistTitle)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top, 6)
                        .padding(.bottom, 4)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.purple.opacity(0.15))
                        .cornerRadius(14)

                    if let url = URL(string: playlistURL) {
                        Link("Tap to open in \(selectedService)", destination: url)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.purple)
                            .cornerRadius(14)
                    }

                    HStack {
                        NavigationLink(destination: MoodJournalView()) {
                            Label("Mood Journal", systemImage: "book")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }

                        Spacer()

                        NavigationLink(destination: FavoritesView()) {
                            Label("Favorites", systemImage: "heart.fill")
                                .font(.subheadline)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .padding(.top, 30)
                .padding()
                .background(Color.primary.opacity(0.05).blendMode(.overlay))
                .cornerRadius(14)
            }

            // Removed bottom MoodPlay title for cleaner layout
                    }
                    .padding(.bottom, 40)
                }
                .padding(.vertical)
                .padding(.top, 40)
                // End ScrollView

                // AniView floating above all other elements, can move across the screen
                AniView(mood: selectedMood ?? Mood(name: "Happy", emoji: "😀"))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .zIndex(1)
            }
//            .navigationTitle("MoodPlay")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                if !showSettings {
                    Button(action: {
                        showSettings.toggle()
                    }) {
                        Image(systemName: "gearshape")
                            .imageScale(.large)
                            .foregroundColor(.primary)
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            NavigationView {
                Form {
                    Section(header: Text("Appearance")) {
                        Toggle("Dark Mode", isOn: $isDarkMode)
                    }

                    Section(header: Text("User")) {
                        Text("Username: \(username)")
                    }

                    Section(header: Text("Music Platform")) {
                        Picker("Select your preferred music service", selection: $selectedService) {
                            Text("Spotify").tag("Spotify")
                            Text("Apple Music").tag("Apple Music")
                            Text("YouTube Music").tag("YouTube Music")
                            Text("Other").tag("Other")
                        }
                        .pickerStyle(MenuPickerStyle())
                    }

                    Section {
                        Button(role: .destructive) {
                            loginSuccessful = false
                            isUsernameSet = false
                            spotifyConnected = false
                            loggedInAsGuest = false
                        } label: {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Log Out")
                            }
                        }
                    }
                }
                .navigationTitle("Settings")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") {
                            showSettings = false
                        }
                    }
                }
            }
        }
        .background(
            ZStack {
                selectedMoodGradient
                    .animation(.easeInOut(duration: 0.5), value: selectedMood)
                    .edgesIgnoringSafeArea(.all)
            }
        )
        .preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}


// MARK: - Helper Views

extension ContentView {
    private func trackCardView(for track: SpotifyTrack) -> some View {
        VStack(alignment: .leading) {
            AsyncImage(url: URL(string: track.album.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
            } placeholder: {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 100, height: 100)
                    .cornerRadius(8)
            }
            
            Text(track.name)
                .font(.caption2)
                .fontWeight(.semibold)
                .lineLimit(1)
            
            Text(track.artist)
                .font(.caption2)
                .foregroundColor(.gray)
                .lineLimit(1)
            
            let durationMs = track.durationMs >= 0 ? track.durationMs : 0
            let durationMinutes = durationMs / 60000
            let durationSeconds = (durationMs % 60000) / 1000
            let formattedDuration = "\(durationMinutes):\(String(format: "%02d", durationSeconds))"
            
            Text(formattedDuration)
                .font(.caption2)
                .foregroundColor(.secondary)
            
            if let url = URL(string: track.externalURL) {
                Link(destination: url) {
                    Image(systemName: "play.circle.fill")
                        .foregroundColor(.green)
                        .font(.body)
                }
                .padding(.top, 4)
            }
        }
    }
}
// End of ContentView extension

// End of ContentView struct
