import Foundation

struct Quote: Codable {
    let text: String
    let source: String
    let length: Int
    let id: Int
}

struct QuoteList: Codable {
    let language: String
    let groups: [QuoteGroup]
}

struct QuoteGroup: Codable {
    let name: String
    let quotes: [Quote]
}

class QuoteService {
    static func loadQuotes(language: String = "english") -> [Quote] {
        // Default quotes since we don't have the JSON files yet
        return [
            Quote(text: "The quick brown fox jumps over the lazy dog.", source: "Typing Practice", length: 44, id: 1),
            Quote(text: "To be or not to be, that is the question.", source: "Shakespeare - Hamlet", length: 42, id: 2),
            Quote(text: "All that glitters is not gold.", source: "Shakespeare - Merchant of Venice", length: 29, id: 3),
            Quote(text: "Life is like a box of chocolates. You never know what you're gonna get.", source: "Forrest Gump", length: 71, id: 4),
            Quote(text: "May the Force be with you.", source: "Star Wars", length: 24, id: 5),
            Quote(text: "Elementary, my dear Watson.", source: "Sherlock Holmes", length: 26, id: 6),
            Quote(text: "I think therefore I am.", source: "René Descartes", length: 23, id: 7),
            Quote(text: "That's one small step for man, one giant leap for mankind.", source: "Neil Armstrong", length: 56, id: 8),
            Quote(text: "To infinity and beyond!", source: "Buzz Lightyear", length: 23, id: 9),
            Quote(text: "Be the change you wish to see in the world.", source: "Mahatma Gandhi", length: 44, id: 10)
        ]
    }
}
