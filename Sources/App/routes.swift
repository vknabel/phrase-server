import Crypto
import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    let userController = UserController()
    router.post("users", use: userController.create)

    let basic = router.grouped(User.basicAuthMiddleware(using: BCryptDigest()))
    basic.post("login", use: userController.login)

    let bearer = router.grouped(User.tokenAuthMiddleware())
    let phraseController = PhraseController()
    bearer.get("phrase/own", use: phraseController.ownedPhrases)
    bearer.get("phrase/authored", use: phraseController.authoredPhrases)
    bearer.put("phrase/trade", Phrase.parameter, use: phraseController.authoredPhrases)
    bearer.post("phrase", use: phraseController.createPhrase)

    let messsageController = MessageController()
    bearer.get("messages", Phrase.parameter, use: messsageController.conversation)
    bearer.post("messages", use: messsageController.send)
}
