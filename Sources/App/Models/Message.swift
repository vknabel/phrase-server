import FluentSQLite
import Vapor

final class Message: SQLiteModel {
    var id: Int?
    var text: String
    var phraseID: Phrase.ID
    var sendByAuthor: Bool
    var date: Date

    init(id: Int? = nil, text: String, phraseID: Phrase.ID, sendByAuthor: Bool, date: Date = Date()) {
        self.id = id
        self.text = text
        self.phraseID = phraseID
        self.sendByAuthor = sendByAuthor
        self.date = date
    }
}

extension Message {
    var phrase: Parent<Message, Phrase> {
        return parent(\.phraseID)
    }
}

extension Message: Migration {
    static func prepare(on conn: SQLiteConnection) -> Future<Void> {
        return SQLiteDatabase.create(Message.self, on: conn) { builder in
            builder.field(for: \.id, isIdentifier: true)
            builder.field(for: \.text)
            builder.field(for: \.date)
            builder.field(for: \.sendByAuthor)
            builder.field(for: \.phraseID)
            builder.reference(from: \.phraseID, to: \User.id)
        }
    }
}

extension Message: Content {}
extension Message: Parameter {}
