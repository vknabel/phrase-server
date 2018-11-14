import FluentSQLite
import NIO
import Vapor

final class PhraseController {
    func ownedPhrases(_ req: Request) throws -> Future<[Phrase]> {
        let user = try req.requireAuthenticated(User.self)
        return try Phrase.query(on: req)
            .filter(\.ownerID == user.requireID()).all()
    }

    func authoredPhrases(_ req: Request) throws -> Future<[Phrase]> {
        let user = try req.requireAuthenticated(User.self)
        return try Phrase.query(on: req)
            .filter(\.authorID == user.requireID()).all()
    }

    func createPhrase(_ req: Request) throws -> Future<[Phrase]> {
        let user = try req.requireAuthenticated(User.self)
        return try req.content.decode(json: CreatePhraseRequest.self, using: JSONDecoder()).flatMap { phraseData in
            let newPhrase = try Phrase(
                authorID: user.requireID(),
                backgroundColor: phraseData.backgroundColor,
                foregroundColor: phraseData.foregroundColor,
                lines: phraseData.lines
            )
            return newPhrase.save(on: req)
                .flatMap { _ in
                    try self.unownedPhrase(req: req, userID: user.requireID())
                }
                .map { CreatePhraseResponse(created: newPhrase, received: $0) }
        }
    }

    func trade(req: Request) throws -> Future<Phrase?> {
        let user = try req.requireAuthenticated(User.self)
        return try req.parameters.next(Phrase.self).flatMap { phrase -> Future<Phrase?> in
            guard try phrase.ownerID == user.requireID() else {
                throw Abort(.forbidden)
            }

            phrase.ownerID = nil
            return phrase.save(on: req).flatMap { _ in
                try self.unownedPhrase(req: req, userID: user.requireID())
            }
        }
    }

    private func unownedPhrase(req: Request, userID: User.ID) -> Future<Phrase?> {
        return Phrase.query(on: req)
            .filter(\.ownerID == nil)
            .filter(\.authorID != userID)
            // .sort(\.score)
            .first()
            .flatMap { (phrase: Phrase?) throws -> Future<Phrase?> in
                if let phrase = phrase {
                    phrase.ownerID = userID
                    return phrase.save(on: req).map(Optional.init)
                } else {
                    return req.eventLoop.newSucceededFuture(result: nil)
                }
            }
    }
}

struct CreatePhraseRequest: Codable {
    var lines: [Line]
    var backgroundColor: Color
    var foregroundColor: Color
}

struct CreatePhraseResponse: Codable {
    var created: Phrase
    var received: Phrase
}
