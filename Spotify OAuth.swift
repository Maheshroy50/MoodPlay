//
//  SpotifyOAuth.swift
//  MoodPlay
//
//  Created by Mahesh Rao on 7/23/25.
//

import Foundation
import AuthenticationServices
import UIKit

final class SpotifyAuthManager: NSObject, ObservableObject {
    static let shared = SpotifyAuthManager()
    private var authSession: ASWebAuthenticationSession?

    private let clientID = "10cb3654d70547d6b7ce6c352630180b" 
    private let redirectURI = "moodplay://callback"

    var accessToken: String? {
        return retrieveToken(for: "SpotifyAccessToken")
    }

    var refreshToken: String? {
        return retrieveToken(for: "SpotifyRefreshToken")
    }

    func startLogin() {
        let scope = "user-read-private user-read-email"
        let state = UUID().uuidString

        guard let encodedRedirectURI = redirectURI.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
              let encodedScope = scope.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            print("Failed to encode URI or Scope")
            return
        }

        let urlString = "https://accounts.spotify.com/authorize?client_id=\(clientID)&response_type=code&redirect_uri=\(encodedRedirectURI)&scope=\(encodedScope)&state=\(state)"

        guard let authURL = URL(string: urlString) else {
            print("Invalid Auth URL")
            return
        }

        authSession = ASWebAuthenticationSession(url: authURL, callbackURLScheme: "moodplay") { callbackURL, error in
            guard error == nil,
                  let url = callbackURL,
                  let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
                  let code = components.queryItems?.first(where: { $0.name == "code" })?.value else {
                print("Auth failed:", error?.localizedDescription ?? "No code received")
                return
            }

            self.exchangeCodeForToken(code: code)
        }

        authSession?.presentationContextProvider = self
        authSession?.start()
    }

    private func exchangeCodeForToken(code: String) {
        guard let url = URL(string: "https://backend-d1fj.onrender.com/spotifyCallback") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["code": code]
        guard let httpBody = try? JSONSerialization.data(withJSONObject: body, options: []) else { return }
        request.httpBody = httpBody

        URLSession.shared.dataTask(with: request) { data, _, error in
            guard error == nil,
                  let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let accessToken = json["access_token"] as? String else {
                print("Failed to get token")
                return
            }

            self.storeTokenInKeychain(token: accessToken, key: "SpotifyAccessToken")

            if let refreshToken = json["refresh_token"] as? String {
                self.storeTokenInKeychain(token: refreshToken, key: "SpotifyRefreshToken")
            }

            DispatchQueue.main.async {
                UserDefaults.standard.set(true, forKey: "spotifyConnected")
                self.presentSpotifySuccessAlert()
            }
        }.resume()
    }

    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refreshToken = self.refreshToken else {
            completion(false)
            return
        }

        guard let url = URL(string: "https://accounts.spotify.com/api/token") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")

        let params = [
            "grant_type": "refresh_token",
            "refresh_token": refreshToken
        ]

        request.httpBody = params
            .map { "\($0)=\($1)" }
            .joined(separator: "&")
            .data(using: String.Encoding.utf8)

        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let newToken = json["access_token"] as? String else {
                completion(false)
                return
            }

            self.storeTokenInKeychain(token: newToken, key: "SpotifyAccessToken")
            completion(true)
        }.resume()
    }

    func getAccessToken(completion: @escaping (String?) -> Void) {
        // If we already have a valid access token, return it
        if let token = self.accessToken {
            completion(token)
            return
        }

        // Otherwise, attempt to refresh the token
        refreshAccessToken { success in
            if success, let refreshedToken = self.accessToken {
                completion(refreshedToken)
            } else {
                print("Failed to refresh access token.")
                completion(nil)
            }
        }
    }

    private func storeTokenInKeychain(token: String, key: String) {
        guard let tokenData = token.data(using: String.Encoding.utf8) else { return }

        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: tokenData
        ]

        SecItemDelete(query as CFDictionary)
        SecItemAdd(query as CFDictionary, nil)
    }

    private func retrieveToken(for key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        if status == errSecSuccess,
           let data = result as? Data,
           let token = String(data: data, encoding: String.Encoding.utf8) {
            return token
        }
        return nil
    }
    
    // Helper to present a success alert on the main thread
    private func presentSpotifySuccessAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Spotify Connected",
                                          message: "✅ Successfully logged in with Spotify",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            // Find the topmost view controller to present the alert
            if let topVC = UIApplication.shared.windows.first(where: { $0.isKeyWindow })?.rootViewController {
                var presentedVC = topVC
                while let next = presentedVC.presentedViewController {
                    presentedVC = next
                }
                presentedVC.present(alert, animated: true, completion: nil)
            }
        }
    }
}

extension SpotifyAuthManager: ASWebAuthenticationPresentationContextProviding {
    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        if #available(iOS 15.0, *) {
            return UIApplication.shared.connectedScenes
                .compactMap { ($0 as? UIWindowScene)?.keyWindow }
                .first ?? ASPresentationAnchor()
        } else {
            return UIApplication.shared.windows.first ?? ASPresentationAnchor()
        }
    }
}
