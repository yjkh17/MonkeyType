import Foundation

class TypingTestModel: ObservableObject {
    @Published var currentWords: [String] = []
    @Published var userInput: String = ""
    @Published var currentIndex: Int = 0
    @Published var isTestActive: Bool = false
    
    func loadWords() {
        // For now, let's use a simple word list
        let basicWords = ["the", "be", "to", "of", "and", "a", "in", "that", "have", "I", 
                         "it", "for", "not", "on", "with", "he", "as", "you", "do", "at"]
        currentWords = basicWords.shuffled()
    }
    
    func startTest() {
        loadWords()
        isTestActive = true
        currentIndex = 0
        userInput = ""
    }
}