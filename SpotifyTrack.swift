//
//  SpotifyTrack.swift
//  MoodPlay MoodPlay MoodPlay
//
//  Created by Mahesh Rao on 7/23/25.
//

import Foundation

struct SpotifyTrack: Identifiable, Codable {
    var id: String { uri }
    let name: String
    let artist: String
    let album: Album
    let uri: String
    let durationMs: Int
    let externalURL: String
}

struct Album: Codable {
    let name: String
    let imageURL: String
}
