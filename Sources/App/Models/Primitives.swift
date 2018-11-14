import Fluent

enum Color: String, Codable, ReflectionDecodable {
    case light, dark, red, green, blue

    static func reflectDecoded() -> (Color, Color) {
        return (.light, .dark)
    }
}

enum ContentSize: Int, Codable, ReflectionDecodable {
    case small, medium, tall

    static func reflectDecoded() -> (ContentSize, ContentSize) {
        return (.small, .tall)
    }
}

enum FontType: String, Codable, ReflectionDecodable {
    case langdon, other

    static func reflectDecoded() -> (FontType, FontType) {
        return (.langdon, .other)
    }
}

struct Line: Equatable, Codable, ReflectionDecodable {
    var content: String
    var size: ContentSize
    var fontType: FontType

    static func reflectDecoded() -> (Line, Line) {
        return (
            Line(content: "Hello", size: .small, fontType: .langdon),
            Line(content: "World", size: .medium, fontType: .other)
        )
    }
}
