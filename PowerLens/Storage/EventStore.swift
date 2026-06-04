import Foundation
import GRDB

extension PowerEvent: FetchableRecord, PersistableRecord {
    static let databaseTableName = "power_event"

    enum Columns {
        static let id = Column("id")
        static let timestamp = Column("timestamp")
        static let appName = Column("appName")
        static let bundleIdentifier = Column("bundleIdentifier")
        static let powerScore = Column("powerScore")
        static let reasonTags = Column("reasonTags")
        static let suggestions = Column("suggestions")
    }
}

final class EventStore: @unchecked Sendable {
    private let dbQueue: DatabaseQueue
    private let queue = DispatchQueue(label: "com.powerlens.eventstore", qos: .utility)

    init() throws {
        let appSupport = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        let dbDir = appSupport.appendingPathComponent("Power Lens", isDirectory: true)
        try FileManager.default.createDirectory(at: dbDir, withIntermediateDirectories: true)
        let dbPath = dbDir.appendingPathComponent("events.sqlite")
        dbQueue = try DatabaseQueue(path: dbPath.path)
        try createTables()
    }

    private func createTables() throws {
        try dbQueue.write { db in
            try db.create(table: PowerEvent.databaseTableName, ifNotExists: true) { t in
                t.column(PowerEvent.Columns.id.name, .text).primaryKey()
                t.column(PowerEvent.Columns.timestamp.name, .datetime).notNull()
                t.column(PowerEvent.Columns.appName.name, .text).notNull()
                t.column(PowerEvent.Columns.bundleIdentifier.name, .text)
                t.column(PowerEvent.Columns.powerScore.name, .integer).notNull()
                t.column(PowerEvent.Columns.reasonTags.name, .jsonText).notNull()
                t.column(PowerEvent.Columns.suggestions.name, .jsonText).notNull()
            }
        }
    }

    func insert(_ event: PowerEvent) throws {
        try queue.sync {
            try dbQueue.write { db in
                try event.insert(db)
            }
        }
    }

    func insertAsync(_ event: PowerEvent) {
        queue.async { [self] in
            try? insert(event)
        }
    }

    func fetchLast24Hours() throws -> [PowerEvent] {
        try queue.sync {
            let cutoff = Date().addingTimeInterval(-86400)
            return try dbQueue.read { db in
                try PowerEvent
                    .filter(PowerEvent.Columns.timestamp >= cutoff)
                    .order(PowerEvent.Columns.timestamp.desc)
                    .fetchAll(db)
            }
        }
    }

    func deleteAll() throws {
        try queue.sync {
            try dbQueue.write { db in
                try PowerEvent.deleteAll(db)
            }
        }
    }

    func deleteOlderThan(days: Int) throws {
        try queue.sync {
            let cutoff = Calendar.current.date(byAdding: .day, value: -days, to: Date()) ?? Date()
            try dbQueue.write { db in
                try PowerEvent
                    .filter(PowerEvent.Columns.timestamp < cutoff)
                    .deleteAll(db)
            }
        }
    }
}
