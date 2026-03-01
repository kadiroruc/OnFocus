import Foundation

struct PendingSession: Codable {
    let session: SessionModel
    let userId: String
    let createdAt: Date
}

final class PendingSessionStore {
    private let fileURL: URL
    private let queue = DispatchQueue(label: "com.onfocus.pendingSessions.store")

    init(fileName: String = "pending_sessions.json") {
        let baseDirectory = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
            ?? FileManager.default.temporaryDirectory
        let directory = baseDirectory.appendingPathComponent("OnFocus", isDirectory: true)
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        self.fileURL = directory.appendingPathComponent(fileName)
    }

    func load() -> [PendingSession] {
        queue.sync {
            loadInternal()
        }
    }

    func append(_ item: PendingSession) -> Bool {
        queue.sync {
            var items = loadInternal()
            if items.contains(where: { $0.session.id == item.session.id && $0.userId == item.userId }) {
                return false
            }
            items.append(item)
            saveInternal(items)
            return true
        }
    }

    func remove(sessionIds: Set<String>) -> Int {
        queue.sync {
            var items = loadInternal()
            let originalCount = items.count
            items.removeAll { sessionIds.contains($0.session.id) }
            if items.count != originalCount {
                saveInternal(items)
            }
            return originalCount - items.count
        }
    }

    private func loadInternal() -> [PendingSession] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return []
        }
        return (try? JSONDecoder().decode([PendingSession].self, from: data)) ?? []
    }

    private func saveInternal(_ items: [PendingSession]) {
        guard let data = try? JSONEncoder().encode(items) else {
            return
        }
        try? data.write(to: fileURL, options: [.atomic])
    }
}
