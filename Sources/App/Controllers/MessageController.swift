import FluentSQLite
import NIO
import Vapor

final class MessageController {
    func conversation(_ req: Request) throws -> Future<[Message]> {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Phrase.self).flatMap { phrase -> Future<[Message]> in
            guard phrase.ownerID == user.id || phrase.authorID == user.id else {
                throw Abort(.forbidden)
            }
            return try Message.query(on: req)
                .filter(\Message.phraseID == phrase.requireID())
                .sort(\.date)
                .all()
        }
    }

    func send(_ req: Request) throws -> Future<Message> {
        let user = try req.requireAuthenticated(User.self)
        return try req.content.decode(SendMessageRequest.self).flatMap { sendMessageRequest -> Future<Message> in
            Phrase.query(on: req).filter(\.id == sendMessageRequest.phraseID).first()
                .flatMap { phrase in
                    guard let phrase = phrase else { throw Abort(.notFound) }
                    guard phrase.ownerID == user.id || phrase.authorID == user.id else {
                        throw Abort(.forbidden)
                    }
                    let message = Message(
                        text: sendMessageRequest.text,
                        phraseID: sendMessageRequest.phraseID,
                        sendByAuthor: phrase.authorID == user.id
                    )
                    return message.save(on: req)
                }
        }
    }
}

struct SendMessageRequest: Content {
    var phraseID: Phrase.ID
    var text: String
}
