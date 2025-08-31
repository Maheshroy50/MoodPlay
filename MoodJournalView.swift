//
//  MoodJournalView.swift
//  MoodPlay MoodPlay MoodPlay
//
//  Created by Mahesh Rao on 7/22/25.
//

import SwiftUI

struct MoodJournalEntry: Identifiable, Codable {
    let id = UUID()
    let date: Date
    let mood: String
    let note: String
}

class MoodJournalManager: ObservableObject {
    @Published var entries: [MoodJournalEntry] = [] {
        didSet {
            saveEntries()
        }
    }

    private let key = "moodJournalEntries"

    init() {
        loadEntries()
    }

    func addEntry(mood: String, note: String) {
        let entry = MoodJournalEntry(date: Date(), mood: mood, note: note)
        entries.insert(entry, at: 0)
    }

    private func saveEntries() {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    private func loadEntries() {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([MoodJournalEntry].self, from: data) {
            entries = decoded
        }
    }
}

struct MoodJournalView: View {
    @StateObject private var journalManager = MoodJournalManager()
    @State private var showingAddEntry = false
    @State private var selectedMood = ""
    @State private var note = ""

    var body: some View {
        NavigationView {
            List {
                ForEach(journalManager.entries) { entry in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(entry.mood)
                            .font(.headline)
                        Text(entry.note)
                            .font(.subheadline)
                        Text(entry.date, style: .date)
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("Mood Journal")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingAddEntry = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddEntry) {
                NavigationView {
                    Form {
                        Section(header: Text("Mood")) {
                            TextField("e.g. Happy 😀", text: $selectedMood)
                        }
                        Section(header: Text("Note")) {
                            TextField("How are you feeling?", text: $note)
                        }
                    }
                    .navigationTitle("New Entry")
                    .navigationBarItems(leading: Button("Cancel") {
                        showingAddEntry = false
                    }, trailing: Button("Save") {
                        if !selectedMood.isEmpty && !note.isEmpty {
                            journalManager.addEntry(mood: selectedMood, note: note)
                            selectedMood = ""
                            note = ""
                            showingAddEntry = false
                        }
                    })
                }
            }
        }
    }
}
