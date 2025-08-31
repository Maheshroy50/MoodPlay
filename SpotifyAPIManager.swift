//
//  SpotifyAPIManager.swift
//  MoodPlay
//
//  Created by Mahesh Rao on 7/23/25.
//

import Foundation

/// Singleton class to interact with Spotify Web API
class SpotifyAPIManager {
    static let shared = SpotifyAPIManager()
    private init() {}

    /// Search for Spotify tracks based on a mood or keyword
    func searchTracks(mood: String, accessToken: String, completion: @escaping ([SpotifyTrack]) -> Void) {
        let escapedQuery = mood.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? mood
        let endpoint = "https://api.spotify.com/v1/search?q=\(escapedQuery)&type=track&limit=10"

        guard let url = URL(string: endpoint) else {
            print("Invalid URL: \(endpoint)")
            completion([])
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Request failed: \(error.localizedDescription)")
                completion([])
                return
            }

            guard let data = data else {
                print("No data received from Spotify")
                completion([])
                return
            }

            do {
                let tracks = try self.parseTracks(from: data)
                DispatchQueue.main.async {
                    completion(tracks)
                }
            } catch {
                print("Parsing error: \(error.localizedDescription)")
                completion([])
            }
        }.resume()
    }

    /// Parse the Spotify JSON response into model objects
    private func parseTracks(from data: Data) throws -> [SpotifyTrack] {
        guard
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
            let tracksDict = json["tracks"] as? [String: Any],
            let items = tracksDict["items"] as? [[String: Any]]
        else {
            throw NSError(domain: "SpotifyParsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid JSON structure"])
        }

        return items.compactMap { item in
            guard
                let id = item["id"] as? String,
                let name = item["name"] as? String,
                let duration = item["duration_ms"] as? Int,
                let externalURLs = item["external_urls"] as? [String: Any],
                let externalURL = externalURLs["spotify"] as? String,
                let albumDict = item["album"] as? [String: Any],
                let images = albumDict["images"] as? [[String: Any]],
                let imageURL = images.first?["url"] as? String,
                let artists = item["artists"] as? [[String: Any]],
                let artistName = artists.first?["name"] as? String
            else {
                return nil
            }

            let albumName = albumDict["name"] as? String ?? "Unknown Album"
            let uri = item["uri"] as? String ?? ""
            let album = Album(name: albumName, imageURL: imageURL)

            return SpotifyTrack(name: name, artist: artistName, album: album, uri: uri, durationMs: duration, externalURL: externalURL)
        }
    }

    /// Fetch access token via SpotifyAuthManager
    private func fetchAccessToken(completion: @escaping (String?) -> Void) {
        SpotifyAuthManager.shared.getAccessToken { token in
            if let token = token {
                completion(token)
            } else {
                print("Failed to fetch token")
                completion(nil)
            }
        }
    }
}
