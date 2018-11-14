import FluentSQLite
import Vapor

final class Phrase: SQLiteModel {
    var id: Int?
    var authorID: User.ID
    var ownerID: User.ID?
    var lines: [Line]
    var backgroundColor: Color
    var foregroundColor: Color

    init(id: Int? = nil, ownerID: User.ID? = nil, authorID: User.ID, backgroundColor: Color, foregroundColor: Color, lines: [Line]) {
        self.id = id
        self.ownerID = ownerID
        self.authorID = authorID
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
        self.lines = lines
    }
}

extension Phrase {
    var owner: Parent<Phrase, User>? {
        return parent(\.ownerID)
    }

    var author: Parent<Phrase, User> {
        return parent(\.authorID)
    }
}

extension Phrase: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Phrase.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.backgroundColor)
            builder.field(for: \.foregroundColor)
            builder.field(for: \.lines)
            builder.field(for: \.ownerID)
            builder.reference(from: \.ownerID, to: \User.id)
            builder.field(for: \.authorID)
            builder.reference(from: \.authorID, to: \User.id)
        }
    }
}

extension Phrase: Content {}
extension Phrase: Parameter {}
