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
        guard let url = Bundle.main.url(forResource: "quotes/\(language)", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let quoteList = try? JSONDecoder().decode(QuoteList.self, from: data) else {
            return []
        }
        return quoteList.groups.flatMap { $0.quotes }
    }
}