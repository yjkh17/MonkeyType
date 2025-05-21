import Foundation

struct WordList: Codable {
    let name: String
    let words: [String]
    let noLazyMode: Bool
    let orderedByFrequency: Bool
}

class WordService {
    static let availableLanguages = [
        "english",
        "english_1k",
        "english_10k",
        "english_commonly_misspelled",
        "english_quotes",
        "code_python",
        "code_javascript",
        "code_html"
    ]
    
    static func loadLanguageFile(_ name: String) -> [String] {
        // Handle code languages
        if name.hasPrefix("code_") {
            return loadCodeSnippets(language: name)
        }
        
        // Regular word lists
        guard let url = Bundle.main.url(forResource: name, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let wordList = try? JSONDecoder().decode(WordList.self, from: data) else {
            return defaultWordList
        }
        return wordList.words
    }
    
    private static func loadCodeSnippets(language: String) -> [String] {
        // Default snippets if file not found
        let defaultSnippets = [
            "function hello() {",
            "console.log('Hello');",
            "return true;",
            "const x = 42;",
            "if (condition) {",
            "} else {",
            "for (let i = 0; i < 10; i++) {"
        ]
        
        guard let url = Bundle.main.url(forResource: language, withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let snippets = try? JSONDecoder().decode([String].self, from: data) else {
            return defaultSnippets
        }
        return snippets
    }
    
    static func loadQuotes(_ language: String = "english") -> [Quote] {
        guard let url = Bundle.main.url(forResource: "quotes/\(language)", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let quoteList = try? JSONDecoder().decode(QuoteList.self, from: data) else {
            return []
        }
        return quoteList.groups.flatMap { $0.quotes }
    }
    
    static let defaultWordList = [
        "the", "be", "to", "of", "and", "a", "in", "that", "have", "I",
        "it", "for", "not", "on", "with", "he", "as", "you", "do", "at",
        "this", "but", "his", "by", "from", "they", "we", "say", "her", "she"
    ]
}
