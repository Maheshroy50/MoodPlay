//
//  MoodLogger.swift
//  MoodPlay MoodPlay MoodPlay
//
//  Created by Mahesh Rao on 7/24/25.
//


import Foundation
import FirebaseFirestore
import FirebaseAuth

class MoodLogger {
    static let shared = MoodLogger()
    
    private let db = Firestore.firestore()
    
    private init() {}

    func logMood(_ mood: String, notes: String? = nil, completion: ((Error?) -> Void)? = nil) {
        guard let user = Auth.auth().currentUser else {
            print("No authenticated user found.")
            completion?(NSError(domain: "", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        let data: [String: Any] = [
            "mood": mood,
            "timestamp": Timestamp(date: Date()),
            "userId": user.uid,
            "notes": notes ?? ""
        ]
        
        db.collection("moodEntries").addDocument(data: data) { error in
            if let error = error {
                print("Error logging mood: \(error.localizedDescription)")
                completion?(error)
            } else {
                print("Mood successfully logged.")
                completion?(nil)
            }
        }
    }
}
