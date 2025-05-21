import Foundation

class TypingTestModel: ObservableObject {
    @Published var currentWords: [String] = []
    @Published var userInput: String = ""
    @Published var currentIndex: Int = 0
    @Published var isTestActive: Bool = false
    @Published var currentWordIsCorrect: Bool = true
    @Published var targetWordCount: Int = 0
    @Published var completedWords: Int = 0
    
    @Published var timeRemaining: Int = 30
    @Published var wpm: Double = 0
    @Published var rawWpm: Double = 0
    @Published var accuracy: Double = 0
    @Published var correctChars: Int = 0
    @Published var incorrectChars: Int = 0
    @Published var totalCharsTyped: Int = 0
    @Published var charsPerSecond: Double = 0
    
    @Published var currentWordStart: Int = 0  // Track start position of current word
    @Published var currentWordLength: Int = 0 // Track length of current word
    @Published var extraChars: Int = 0        // Track extra chars beyond word length
    
    @Published var allTypedChars: Int = 0     // All characters typed, including spaces
    @Published var consecutiveCorrect: Int = 0 // Track correct character streak
    
    @Published private(set) var elapsedTime: TimeInterval = 0
    private var lastCalculation: Date = .distantPast
    private let statsUpdateInterval: TimeInterval = 0.1 // Update stats every 100ms
    
    private var timer: Timer?
    private var startTime: Date?
    private var wordList: [String] = []
    private var quotes: [Quote] = []
    private unowned let settings: Settings
    
    @Published var selectedDuration: TestDuration = .seconds30
    @Published var lastErrorTime: Date = .distantPast
    private let errorCooldown: TimeInterval = 0.1 // 100ms cooldown for error sounds
    
    @Published var currentQuote: Quote? = nil
    
    @Published var wpmHistory: [Double] = []
    @Published var rawWpmHistory: [Double] = []
    private let historyUpdateInterval: TimeInterval = 0.5 // Update every 500ms
    private var lastHistoryUpdate: Date = .distantPast
    
    @Published var progress: Double = 0
    @Published var errorRate: Double = 0
    @Published var consistencyScore: Double = 0
    @Published var recentWPMs: [Double] = [] // Last 10 WPMs for consistency
    private let recentWPMsLimit = 10
    
    // Add character tracking structures
    struct CharacterStat {
        var attempts: Int = 0
        var correct: Int = 0
        var time: Double = 0
        var lastTyped: Date = .distantPast
        
        var accuracy: Double {
            attempts > 0 ? Double(correct) / Double(attempts) * 100 : 0
        }
    }
    
    @Published var characterStats: [Character: CharacterStat] = [:]
    @Published var mostMissedKeys: [(Character, Int)] = []
    @Published var accuracyPerKey: [Character: Double] = [:]
    
    // Add new properties for typing patterns
    @Published var lastPressTime: [Character: TimeInterval] = [:]
    @Published var keyPressTimes: [Character: [TimeInterval]] = [:]
    @Published var typingSpeed: [TimeInterval] = []
    @Published var consecutiveErrorRate: Double = 0
    @Published var errorLocations: [(index: Int, char: Character)] = []
    
    enum QuoteLength: String, CaseIterable {
        case all
        case short   // < 200 chars
        case medium  // 200-500 chars
        case long    // 500-1000 chars
        case thicc   // > 1000 chars
    }
    
    enum TestDuration: Int, CaseIterable {
        case seconds15 = 15
        case seconds30 = 30
        case seconds60 = 60
        case seconds120 = 120
        
        var description: String {
            "\(self.rawValue)s"
        }
    }
    
    enum TestState {
        case idle
        case active
        case finished
    }
    
    @Published private(set) var testState: TestState = .idle
    private var debounceTimer: Timer?
    private let debounceInterval: TimeInterval = 1.0
    
    private var lastWordLength: Int = 0    // Track previous word length for better transitions
    private var soundThrottle: Int = 0     // Throttle rapid sounds
    private let maxSoundRate: Int = 10     // Max sounds per second
    
    private var lastInputLength: Int = 0   // Track input length for backspace handling
    private var isBackspacing: Bool = false // Track if user is backspacing
    
    private var soundCooldown: TimeInterval = 0.05 // 50ms between sounds
    private var lastSoundTime: Date = .distantPast
    
    private var testInitiated: Bool = false
    
    private func playSound(_ type: SoundManager.SoundType) {
        guard settings.soundEnabled else { return }
        
        let now = Date()
        if now.timeIntervalSince(lastSoundTime) >= soundCooldown {
            SoundManager.shared.playSound(type)
            lastSoundTime = now
        }
    }
    
    init(settings: Settings) {
        self.settings = settings
    }
    
    func startTest() {
        testInitiated = false
        timer?.invalidate()
        timer = nil
        
        testState = .active
        isTestActive = true
        currentIndex = 0
        userInput = ""
        currentWordIsCorrect = true
        completedWords = 0
        wpm = 0
        rawWpm = 0
        accuracy = 0
        correctChars = 0
        incorrectChars = 0
        startTime = Date()
        elapsedTime = 0
        lastCalculation = .distantPast
        
        // Reset tracking properties
        lastInputLength = 0
        isBackspacing = false
        allTypedChars = 0
        consecutiveCorrect = 0
        currentWordStart = 0
        currentWordLength = 0
        extraChars = 0
        
        // Load fresh content
        loadContent()
        currentWordLength = currentWords.first?.count ?? 0
        
        // Set up timer if needed
        switch settings.testMode {
        case .time:
            timeRemaining = selectedDuration.rawValue
            timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
                self?.updateTimer()
            }
        case .words:
            targetWordCount = settings.wordCount.rawValue
            timeRemaining = -1
        default:
            timeRemaining = -1
        }
        
        NotificationCenter.default.post(name: .hideResults, object: nil)
    }
    
    private func loadContent() {
        switch settings.testMode {
        case .quote:
            quotes = QuoteService.loadQuotes(language: settings.language)
            if let quote = selectQuote() {
                currentQuote = quote
                currentWords = quote.text.components(separatedBy: " ")
            }
        case .custom:
            if !settings.customText.isEmpty {
                currentWords = settings.customText
                    .components(separatedBy: .newlines)
                    .joined(separator: " ")
                    .components(separatedBy: .whitespaces)
                    .filter { !$0.isEmpty }
            } else {
                loadDefaultWords()
            }
        case .numbers:
            currentWords = generateNumbers()
        case .punctuation:
            currentWords = generateWordsWithPunctuation()
        default:
            loadDefaultWords()
        }
        
        // Reset word position tracking
        currentWordStart = 0
        currentWordLength = currentWords.first?.count ?? 0
        extraChars = 0
    }
    
    private func selectQuote() -> Quote? {
        let filteredQuotes = quotes.filter { quote in
            switch settings.quoteLength {
            case .short:
                return quote.text.count < 200
            case .medium:
                return quote.text.count >= 200 && quote.text.count < 500
            case .long:
                return quote.text.count >= 500 && quote.text.count < 1000
            case .thicc:
                return quote.text.count >= 1000
            case .all:
                return true
            }
        }
        return filteredQuotes.randomElement()
    }
    
    private func loadDefaultWords() {
        wordList = WordService.loadLanguageFile(settings.language)
        resetWords()
    }
    
    private func generateNumbers() -> [String] {
        let numberCount = 100
        var numbers: [String] = []
        
        for _ in 0..<numberCount {
            switch settings.numbersMode {
            case .advanced:
                // Generate numbers up to 999,999 with commas
                let number = Int.random(in: 0...999999)
                let formatter = NumberFormatter()
                formatter.numberStyle = .decimal
                numbers.append(formatter.string(from: NSNumber(value: number))!)
            case .on:
                // Simple numbers 0-99
                numbers.append(String(Int.random(in: 0...99)))
            case .off:
                break
            }
        }
        
        return numbers.shuffled()
    }
    
    private func generateWordsWithPunctuation() -> [String] {
        let words = WordService.loadLanguageFile(settings.language)
        var modifiedWords: [String] = []
        
        for word in words {
            var modifiedWord = word
            
            if settings.punctuationMode != .off {
                let shouldAddPunctuation = Bool.random()
                if shouldAddPunctuation {
                    modifiedWord = addPunctuation(to: modifiedWord)
                }
            }
            
            modifiedWords.append(modifiedWord)
        }
        
        return modifiedWords.shuffled()
    }
    
    private func addPunctuation(to word: String) -> String {
        let basicPunctuation = [".", ",", "!", "?", ";", ":"]
        let advancedPunctuation = ["\"", "'", "-", "(", ")", "[", "]", "{", "}", "<", ">", "/", "@", "#", "$", "%", "&", "*", "+", "=", "_"]
        
        let punctuation = settings.punctuationMode == .advanced ? 
            basicPunctuation + advancedPunctuation : basicPunctuation
        
        if Bool.random() && !word.isEmpty {
            // Sometimes add punctuation at start for advanced mode
            if settings.punctuationMode == .advanced && Bool.random() {
                return punctuation.randomElement()! + word
            }
            // Otherwise add at end
            return word + punctuation.randomElement()!
        }
        
        return word
    }
    
    private func resetWords() {
        // Get initial set of words
        var words = Array(wordList.shuffled().prefix(50))
        
        // Add numbers if enabled
        if settings.numbersMode != .off {
            let numberWords = generateNumbers()
            words = words.enumerated().map { index, word in
                index % 5 == 0 ? numberWords[index / 5] : word
            }
        }
        
        // Add punctuation if enabled
        if settings.punctuationMode != .off {
            words = words.map { word in
                Bool.random() ? addPunctuation(to: word) : word
            }
        }
        
        currentWords = words
    }
    
    private func updateTimer() {
        if timeRemaining > 0 {
            timeRemaining -= 1
            calculateStats()
            
            if timeRemaining == 0 {
                endTest()
            }
        }
    }
    
    private func endTest() {
        guard testState == .active else { return }
        
        isTestActive = false
        testState = .finished
        timer?.invalidate()
        timer = nil
        calculateStats() // Final stats calculation
        
        if settings.soundEnabled {
            SoundManager.shared.playSound(.complete)
        }
        
        let result = saveResult()
        testHistory.append(result)
        
        // Notify of test completion with results
        NotificationCenter.default.post(
            name: .testComplete,
            object: nil,
            userInfo: ["result": result]
        )
    }
    
    func cancelTest() {
        guard testState == .active else { return }
        
        isTestActive = false
        testState = .idle
        timer?.invalidate()
        timer = nil
        
        // Reset test state
        userInput = ""
        currentWordIsCorrect = true
        
        NotificationCenter.default.post(name: .hideResults, object: nil)
        NotificationCenter.default.post(name: .testCancelled, object: nil)
    }
    
    func restartTest() {
        // Only allow restart if test is finished or idle
        guard testState != .active else { return }
        
        // Hide any existing results
        NotificationCenter.default.post(name: .hideResults, object: nil)
        
        // Start new test
        startTest()
    }
    
    private func calculateStats() {
        guard let start = startTime else { return }
        
        let now = Date()
        guard now.timeIntervalSince(lastCalculation) >= statsUpdateInterval else { return }
        lastCalculation = now
        
        elapsedTime = now.timeIntervalSince(start)
        let timeElapsedMinutes = elapsedTime / 60.0
        
        if timeElapsedMinutes > 0 {
            // Raw WPM = all characters typed / 5 / time
            rawWpm = Double(allTypedChars) / 5.0 / timeElapsedMinutes
            
            // Net WPM = correct characters / 5 / time
            wpm = Double(correctChars) / 5.0 / timeElapsedMinutes
            
            // Update WPM history every 500ms
            if now.timeIntervalSince(lastHistoryUpdate) >= historyUpdateInterval {
                wpmHistory.append(wpm)
                rawWpmHistory.append(rawWpm)
                lastHistoryUpdate = now
            }
            
            // Calculate accuracy and consistency
            let totalAttempted = correctChars + incorrectChars
            accuracy = totalAttempted > 0 ? Double(correctChars) / Double(totalAttempted) * 100 : 0
            
            // Update recent WPMs for consistency calculation
            if !recentWPMs.isEmpty {
                let avg = recentWPMs.reduce(0, +) / Double(recentWPMs.count)
                let variance = recentWPMs.map { pow($0 - avg, 2) }.reduce(0, +) / Double(recentWPMs.count)
                let stdDev = sqrt(variance)
                consistencyScore = max(0, 100 - (stdDev / avg * 100))
            }
            
            // Characters per second
            charsPerSecond = Double(allTypedChars) / elapsedTime
        }
    }
    
    private func updateProgress() {
        switch settings.testMode {
        case .time:
            progress = 1.0 - Double(timeRemaining) / Double(selectedDuration.rawValue)
        case .words:
            progress = Double(completedWords) / Double(targetWordCount)
        case .quote:
            if let totalWords = currentQuote?.text.components(separatedBy: " ").count {
                progress = Double(completedWords) / Double(totalWords)
            }
        case .zen, .custom, .numbers, .punctuation:
            progress = 0 // No progress for these modes
        }
    }
    
    private func updateCharacterStats(_ char: Character, isCorrect: Bool) {
        var stat = characterStats[char] ?? CharacterStat()
        let now = Date()
        
        if let lastTyped = characterStats[char]?.lastTyped {
            stat.time += now.timeIntervalSince(lastTyped)
        }
        
        stat.attempts += 1
        if isCorrect {
            stat.correct += 1
        }
        stat.lastTyped = now
        
        characterStats[char] = stat
        
        // Update most missed keys
        let sortedStats = characterStats.sorted { $0.value.attempts - $0.value.correct > $1.value.attempts - $1.value.correct }
        mostMissedKeys = sortedStats.prefix(5).map { ($0.key, $0.value.attempts - $0.value.correct) }
        
        // Update accuracy per key
        accuracyPerKey = characterStats.mapValues { $0.accuracy }
    }
    
    func handleInput(_ newInput: String) {
        // Start test automatically on first keystroke
        if !isTestActive && testState == .idle && !newInput.isEmpty && !testInitiated {
            // Don't start test if it's just a space or return
            if newInput == " " || newInput == "\n" {
                return
            }
            testInitiated = true
            startTest()
            userInput = newInput
            validateWord()
            return
        }
        
        guard isTestActive else { return }
        
        let wasBackspacing = isBackspacing
        isBackspacing = newInput.count < userInput.count
        
        userInput = newInput
        validateWord()
        
        // Only submit if:
        // 1. We weren't backspacing
        // 2. Have input
        // 3. Input ends with space/return
        // 4. Current word is correct
        if !wasBackspacing && 
           !newInput.isEmpty && 
           (newInput.hasSuffix(" ") || newInput.hasSuffix("\n")) &&
           currentWordIsCorrect {
            submitWord()
        }
    }
    
    func validateWord() {
        guard currentIndex < currentWords.count else { return }
        
        let currentWord = currentWords[currentIndex]
        let input = userInput.trimmingCharacters(in: .whitespaces)
        
        // Handle backspace detection
        isBackspacing = input.count < lastInputLength
        lastInputLength = input.count
        
        var correct = 0
        var incorrect = 0
        
        // Track all typed characters including current input
        allTypedChars = (0..<currentIndex).reduce(0) { sum, idx in 
            sum + currentWords[idx].count + 1 // +1 for space after each word
        } + input.count
        
        // Check character by character
        zip(input, currentWord).forEach { inputChar, wordChar in
            if inputChar == wordChar {
                correct += 1
                if !isBackspacing {
                    consecutiveCorrect += 1
                    updateCharacterStats(inputChar, isCorrect: true)
                    playSound(.keypress)
                }
            } else {
                incorrect += 1
                consecutiveCorrect = 0
                if !isBackspacing {
                    updateCharacterStats(inputChar, isCorrect: false)
                    playSound(.error)
                }
            }
        }
        
        // Count extra characters as incorrect
        if input.count > currentWord.count {
            incorrect += input.count - currentWord.count
        }
        
        correctChars = correct
        incorrectChars = incorrect
        
        if !isBackspacing {
            // Smooth word transition
            if correct == currentWord.count && (input.hasSuffix(" ") || input.hasSuffix("\n")) {
                submitWord()
                return
            }
            
            // Auto-complete if only one character is left and all chars so far are correct
            if correct == input.count && input.count == currentWord.count - 1 && incorrect == 0 {
                userInput += String(currentWord.last!)
                submitWord()
                return
            }
        }
        
        currentWordIsCorrect = input == currentWord
        calculateStats()
    }
    
    func submitWord() {
        guard isTestActive else { return }
        
        let currentWord = currentWords[currentIndex]
        let input = userInput.trimmingCharacters(in: .whitespaces)
        
        if input == currentWord {
            // Store current word length before moving on
            lastWordLength = currentWordLength
            lastInputLength = 0 // Reset input tracking
            
            // Word is correct
            currentIndex += 1
            completedWords += 1
            userInput = ""
            currentWordIsCorrect = true
            isBackspacing = false
            
            // Update word position tracking
            currentWordStart += lastWordLength + 1 // +1 for space
            currentWordLength = currentIndex < currentWords.count ? currentWords[currentIndex].count : 0
            extraChars = 0
            
            // Reset sound throttle on word completion
            soundThrottle = 0
            
            if settings.soundEnabled {
                playSound(.keypress)
            }
            
            // Add more words if needed
            if currentWords.count - currentIndex < 10 {
                currentWords.append(contentsOf: wordList.shuffled())
            }
            
            // Check for word count completion
            if settings.testMode == .words && completedWords >= targetWordCount {
                endTest()
            }
        } else {
            currentWordIsCorrect = false
        }
    }
    
    struct TestResult {
        let wpm: Double
        let rawWpm: Double
        let accuracy: Double
        let duration: Int
        let correctChars: Int
        let incorrectChars: Int
        let date: Date
        let charsPerSecond: Double
        let elapsedTime: TimeInterval
        let characterStats: [Character: CharacterStat]
        let mostMissedKeys: [(Character, Int)]
        let accuracyPerKey: [Character: Double]
        let quote: Quote?
        let totalChars: Int
        let wpmHistory: [Double]
        let rawWpmHistory: [Double]
        
        var consistencyPercent: Double {
            guard let maxWpm = wpmHistory.max(),
                  maxWpm > 0 else { return 0 }
            
            let avgWpm = wpmHistory.reduce(0, +) / Double(wpmHistory.count)
            return (avgWpm / maxWpm) * 100
        }
    }
    
    private func saveResult() -> TestResult {
        TestResult(
            wpm: wpm,
            rawWpm: rawWpm,
            accuracy: accuracy,
            duration: settings.testMode == .time ? selectedDuration.rawValue : Int(elapsedTime),
            correctChars: correctChars,
            incorrectChars: incorrectChars,
            date: Date(),
            charsPerSecond: charsPerSecond,
            elapsedTime: elapsedTime,
            characterStats: characterStats,
            mostMissedKeys: mostMissedKeys,
            accuracyPerKey: accuracyPerKey,
            quote: currentQuote,
            totalChars: correctChars + incorrectChars,
            wpmHistory: wpmHistory,
            rawWpmHistory: rawWpmHistory
        )
    }
    
    @Published var testHistory: [TestResult] = []
    
    @Published var selectedLanguage: String = "english" {
        didSet {
            loadWords()
        }
    }
    
    func loadWords() {
        wordList = WordService.loadLanguageFile(selectedLanguage)
        resetWords()
    }
}
