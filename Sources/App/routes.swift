import Crypto
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let userController = UserController()
    router.post("api/users", use: userController.create)

    let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
    basic.post("api/login", use: userController.login)

    let bearer = router.grouped(User.tokenAuthMiddleware())
    let phraseController = PhraseController()
    bearer.get("api/phrase/own", use: phraseController.ownedPhrases)
    bearer.get("api/phrase/authored", use: phraseController.authoredPhrases)
    bearer.put("api/phrase/trade", Phrase.parameter, use: phraseController.authoredPhrases)
    bearer.post("api/phrase", use: phraseController.createPhrase)

    let messsageController = MessageController()
    bearer.get("api/messages", Phrase.parameter, use: messsageController.conversation)
    bearer.post("api/messages", use: messsageController.send)
}
