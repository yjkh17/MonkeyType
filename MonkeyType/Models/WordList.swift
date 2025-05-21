import Foundation

struct WordList: Codable {
    let name: String
    let words: [String]
    let noLazyMode: Bool
    let orderedByFrequency: Bool
}

class WordService {
    static func loadLanguageFile(_ name: String) -> [String] {
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let wordList = try? JSONDecoder().decode(WordList.self, from: data) else {
            return defaultWordList
        }
        return wordList.words
    }
    
    static let defaultWordList = [
        "the", "be", "to", "of", "and", "a", "in", "that", "have", "I",
        "it", "for", "not", "on", "with", "he", "as", "you", "do", "at",
        "this", "but", "his", "by", "from", "they", "we", "say", "her", "she"
    ]
}