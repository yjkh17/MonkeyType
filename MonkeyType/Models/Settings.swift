import SwiftUI
import Combine

class Settings: ObservableObject {
    enum TestMode: String, CaseIterable {
        case time
        case words
        case quote
        case zen
        case custom
        case numbers
        case punctuation
        
        var description: String {
            switch self {
            case .time: return "time"
            case .words: return "words"
            case .quote: return "quote"
            case .zen: return "zen"
            case .custom: return "custom"
            case .numbers: return "numbers"
            case .punctuation: return "punctuation"
            }
        }
    }
    
    enum WordCount: Int, CaseIterable {
        case ten = 10
        case twenty = 20
        case fifty = 50
        case hundred = 100
        case twohundred = 200
        
        var description: String {
            "\(self.rawValue)"
        }
    }
    
    struct Theme {
        struct Colors {
            let text: Color
            let background: Color
            let accent: Color
            let error: Color
            let success: Color
            let subtext: Color
        }
        
        let name: String
        let colors: Colors
    }
    
    enum NumbersMode: String, CaseIterable {
        case off
        case on
        case advanced
        
        var description: String {
            switch self {
            case .off: return "Off"
            case .on: return "Numbers"
            case .advanced: return "Advanced"
            }
        }
    }
    
    enum PunctuationMode: String, CaseIterable {
        case off
        case normal
        case advanced
        
        var description: String {
            switch self {
            case .off: return "Off"
            case .normal: return "Normal"
            case .advanced: return "Advanced"
            }
        }
    }
    
    enum CaretStyle: String, CaseIterable {
        case off
        case block
        case outline
        case underline
        case smooth
        
        var description: String {
            switch self {
            case .off: return "Off"
            case .block: return "Block"
            case .outline: return "Outline"
            case .underline: return "Underline"
            case .smooth: return "Smooth"
            }
        }
    }
    
    enum Layout: String, CaseIterable {
        case qwerty
        case dvorak
        case colemak
        case workman
        case colemak_dh
        case beakl15
        case norman
        case semimak
        case colemak_dhk
        case mtgap
        
        var description: String {
            switch self {
            case .qwerty: return "QWERTY"
            case .dvorak: return "Dvorak"
            case .colemak: return "Colemak"
            case .workman: return "Workman"
            case .colemak_dh: return "Colemak DH"
            case .beakl15: return "BEAKL 15"
            case .norman: return "Norman"
            case .semimak: return "Semimak"
            case .colemak_dhk: return "Colemak DHk"
            case .mtgap: return "MTGAP"
            }
        }
    }
    
    enum QuoteLength: String, CaseIterable {
        case all
        case short   // < 200 chars
        case medium  // 200-500 chars
        case long    // 500-1000 chars
        case thicc   // > 1000 chars
        
        var description: String {
            switch self {
            case .all: return "all"
            case .short: return "short"
            case .medium: return "medium"
            case .long: return "long"
            case .thicc: return "thicc"
            }
        }
    }
    
    enum LanguageGroup: String, CaseIterable {
        case english
        case code
        case numbers
        case punctuation
        
        var description: String {
            switch self {
            case .english: return "English"
            case .code: return "Code"
            case .numbers: return "Numbers"
            case .punctuation: return "Punctuation"
            }
        }
    }
    
    static let codeLanguages = [
        "code_python": "Python",
        "code_javascript": "JavaScript",
        "code_typescript": "TypeScript",
        "code_rust": "Rust",
        "code_go": "Go",
        "code_cpp": "C++",
        "code_java": "Java",
        "code_csharp": "C#",
        "code_swift": "Swift"
    ]
    
    static let availableLanguages = [
        "english",
        "english_1k",
        "english_10k",
        "code_python",
        "code_javascript",
        "code_typescript",
        "code_rust",
        "code_go",
        "code_cpp",
        "code_java",
        "code_html",
        "code_css"
    ]
    
    let languageVariants = [
        "english",
        "english_1k",
        "english_10k"
    ]
    
    @Published var testMode: TestMode = .time
    @Published var wordCount: WordCount = .fifty
    @Published var numbersMode: NumbersMode = .off {
        didSet {
            UserDefaults.standard.set(numbersMode.rawValue, forKey: "numbersMode")
        }
    }
    
    @Published var punctuationMode: PunctuationMode = .off {
        didSet {
            UserDefaults.standard.set(punctuationMode.rawValue, forKey: "punctuationMode")
        }
    }
    @Published var customText: String = "" {
        didSet {
            UserDefaults.standard.set(customText, forKey: "customText")
        }
    }
    
    @Published var customTextName: String = "" {
        didSet {
            UserDefaults.standard.set(customTextName, forKey: "customTextName")
        }
    }
    
    @Published var customTextVisible: Bool = false {
        didSet {
            UserDefaults.standard.set(customTextVisible, forKey: "customTextVisible")
        }
    }
    @Published var language: String = "english" {
        didSet {
            UserDefaults.standard.set(language, forKey: "language")
        }
    }
    @Published var languageGroup: LanguageGroup = .english {
        didSet {
            UserDefaults.standard.set(languageGroup.rawValue, forKey: "languageGroup")
        }
    }
    @Published var showLiveWPM: Bool = true
    @Published var showLiveAccuracy: Bool = true
    @Published var fontFamily: String = "JetBrains Mono" {
        didSet {
            UserDefaults.standard.set(fontFamily, forKey: "fontFamily")
        }
    }
    @Published var fontSize: Int = 16 {
        didSet {
            UserDefaults.standard.set(fontSize, forKey: "fontSize")
        }
    }
    @Published var theme: Theme = Settings.themes[0] {
        didSet {
            UserDefaults.standard.set(theme.name, forKey: "selectedTheme")
        }
    }
    @Published var soundEnabled: Bool = true {
        didSet {
            UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        }
    }
    
    @Published var playSoundOnClick: Bool = true {
        didSet {
            UserDefaults.standard.set(playSoundOnClick, forKey: "playSoundOnClick")
        }
    }
    
    @Published var playSoundOnError: Bool = true {
        didSet {
            UserDefaults.standard.set(playSoundOnError, forKey: "playSoundOnError")
        }
    }
    
    @Published var soundVolume: Double = 0.5 {
        didSet {
            UserDefaults.standard.set(soundVolume, forKey: "soundVolume")
        }
    }
    
    @Published var clickSoundPack: String = "default" {
        didSet {
            UserDefaults.standard.set(clickSoundPack, forKey: "clickSoundPack")
        }
    }
    @Published var smoothCursor: Bool = true {
        didSet {
            UserDefaults.standard.set(smoothCursor, forKey: "smoothCursor")
        }
    }
    @Published var caretStyle: CaretStyle = .smooth {
        didSet {
            UserDefaults.standard.set(caretStyle.rawValue, forKey: "caretStyle")
        }
    }
    @Published var smoothLineScroll: Bool = true {
        didSet {
            UserDefaults.standard.set(smoothLineScroll, forKey: "smoothLineScroll")
        }
    }
    @Published var quoteLength: QuoteLength = .medium {
        didSet {
            UserDefaults.standard.set(quoteLength.rawValue, forKey: "quoteLength")
        }
    }
    @Published var layout: Layout = .qwerty {
        didSet {
            UserDefaults.standard.set(layout.rawValue, forKey: "keyboardLayout")
        }
    }
    @Published var showKeyboard: Bool = false {
        didSet {
            UserDefaults.standard.set(showKeyboard, forKey: "showKeyboard")
        }
    }
    @Published var keyboardHeight: Int = 80 {
        didSet {
            UserDefaults.standard.set(keyboardHeight, forKey: "keyboardHeight")
        }
    }
    @Published var keyboardOpacity: Double = 0.8 {
        didSet {
            UserDefaults.standard.set(keyboardOpacity, forKey: "keyboardOpacity")
        }
    }
    
    static let themes: [Theme] = [
        Theme(name: "serika_dark", colors: Theme.Colors(
            text: Color(hex: "#e2b714"),
            background: Color(hex: "#323437"),
            accent: Color(hex: "#e2b714"),
            error: Color(hex: "#ca4754"),
            success: Color(hex: "#7ec384"),
            subtext: Color(hex: "#646669")
        )),
        Theme(name: "dracula", colors: Theme.Colors(
            text: Color(hex: "#f8f8f2"),
            background: Color(hex: "#282a36"),
            accent: Color(hex: "#bd93f9"),
            error: Color(hex: "#ff5555"),
            success: Color(hex: "#50fa7b"),
            subtext: Color(hex: "#6272a4")
        )),
        Theme(name: "gruvbox_dark", colors: Theme.Colors(
            text: Color(hex: "#ebdbb2"),
            background: Color(hex: "#282828"),
            accent: Color(hex: "#d79921"),
            error: Color(hex: "#cc241d"),
            success: Color(hex: "#98971a"),
            subtext: Color(hex: "#928374")
        )),
        Theme(name: "nord", colors: Theme.Colors(
            text: Color(hex: "#d8dee9"),
            background: Color(hex: "#2e3440"),
            accent: Color(hex: "#88c0d0"),
            error: Color(hex: "#bf616a"),
            success: Color(hex: "#a3be8c"),
            subtext: Color(hex: "#4c566a")
        )),
        Theme(name: "botanical", colors: Theme.Colors(
            text: Color(hex: "#7b9c98"),
            background: Color(hex: "#1e2326"),
            accent: Color(hex: "#87c095"),
            error: Color(hex: "#e67e80"),
            success: Color(hex: "#a7c080"),
            subtext: Color(hex: "#859289")
        )),
        Theme(name: "dark_magic_girl", colors: Theme.Colors(
            text: Color(hex: "#f5c2e7"),
            background: Color(hex: "#1e1e2e"),
            accent: Color(hex: "#cba6f7"),
            error: Color(hex: "#f38ba8"),
            success: Color(hex: "#a6e3a1"),
            subtext: Color(hex: "#6c7086")
        )),
        Theme(name: "laser", colors: Theme.Colors(
            text: Color(hex: "#ff0099"),
            background: Color(hex: "#221133"),
            accent: Color(hex: "#00ff00"),
            error: Color(hex: "#ff0000"),
            success: Color(hex: "#00ff00"),
            subtext: Color(hex: "#551155")
        )),
        Theme(name: "synthwave", colors: Theme.Colors(
            text: Color(hex: "#ff55ff"),
            background: Color(hex: "#221133"),
            accent: Color(hex: "#00ffff"),
            error: Color(hex: "#ff0066"),
            success: Color(hex: "#00ff00"),
            subtext: Color(hex: "#665599")
        )),
        Theme(name: "sonokai", colors: Theme.Colors(
            text: Color(hex: "#e2e2e3"),
            background: Color(hex: "#2c2e34"),
            accent: Color(hex: "#9ed072"),
            error: Color(hex: "#fc5d7c"),
            success: Color(hex: "#9ed072"),
            subtext: Color(hex: "#7f8490")
        )),
        Theme(name: "terminal", colors: Theme.Colors(
            text: Color(hex: "#33ff33"),
            background: Color(hex: "#000000"),
            accent: Color(hex: "#33ff33"),
            error: Color(hex: "#ff0000"),
            success: Color(hex: "#33ff33"),
            subtext: Color(hex: "#446644")
        ))
    ]
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        if let savedThemeName = UserDefaults.standard.string(forKey: "selectedTheme"),
           let savedTheme = Self.themes.first(where: { $0.name == savedThemeName }) {
            self.theme = savedTheme
        }
        
        if let modeStr = UserDefaults.standard.string(forKey: "testMode"),
           let mode = TestMode(rawValue: modeStr) {
            testMode = mode
        }
        
        if let count = UserDefaults.standard.object(forKey: "wordCount") as? Int,
           let wordCount = WordCount(rawValue: count) {
            self.wordCount = wordCount
        }
        
        self.showKeyboard = UserDefaults.standard.bool(forKey: "showKeyboard")
        
        if let layoutStr = UserDefaults.standard.string(forKey: "keyboardLayout"),
           let savedLayout = Layout(rawValue: layoutStr) {
            self.layout = savedLayout
        }
        
        if let height = UserDefaults.standard.object(forKey: "keyboardHeight") as? Int {
            self.keyboardHeight = height
        }
        
        if let opacity = UserDefaults.standard.object(forKey: "keyboardOpacity") as? Double {
            self.keyboardOpacity = opacity
        }
        
        self.showLiveWPM = UserDefaults.standard.bool(forKey: "showLiveWPM")
        self.showLiveAccuracy = UserDefaults.standard.bool(forKey: "showLiveAccuracy")
        
        if let savedCaretStyle = UserDefaults.standard.string(forKey: "caretStyle"),
           let style = CaretStyle(rawValue: savedCaretStyle) {
            self.caretStyle = style
        }
        
        if let savedLanguage = UserDefaults.standard.string(forKey: "language") {
            self.language = savedLanguage
        }
        
        if let savedQuoteLength = UserDefaults.standard.string(forKey: "quoteLength"),
           let length = QuoteLength(rawValue: savedQuoteLength) {
            self.quoteLength = length
        }
        
        self.customText = UserDefaults.standard.string(forKey: "customText") ?? ""
        self.customTextName = UserDefaults.standard.string(forKey: "customTextName") ?? ""
        self.customTextVisible = UserDefaults.standard.bool(forKey: "customTextVisible")
        
        if let numbersMode = UserDefaults.standard.string(forKey: "numbersMode"),
           let mode = NumbersMode(rawValue: numbersMode) {
            self.numbersMode = mode
        }
        
        if let punctuationMode = UserDefaults.standard.string(forKey: "punctuationMode"),
           let mode = PunctuationMode(rawValue: punctuationMode) {
            self.punctuationMode = mode
        }
        
        if let savedFamily = UserDefaults.standard.string(forKey: "fontFamily") {
            self.fontFamily = savedFamily
        }
        
        if let savedSize = UserDefaults.standard.object(forKey: "fontSize") as? Int {
            self.fontSize = savedSize
        }
        
        self.soundEnabled = UserDefaults.standard.bool(forKey: "soundEnabled")
        self.playSoundOnClick = UserDefaults.standard.bool(forKey: "playSoundOnClick")
        self.playSoundOnError = UserDefaults.standard.bool(forKey: "playSoundOnError")
        
        if let volume = UserDefaults.standard.object(forKey: "soundVolume") as? Double {
            self.soundVolume = volume
        }
        
        if let soundPack = UserDefaults.standard.string(forKey: "clickSoundPack") {
            self.clickSoundPack = soundPack
        }
        
        self.smoothCursor = UserDefaults.standard.bool(forKey: "smoothCursor")
        
        self.smoothLineScroll = UserDefaults.standard.bool(forKey: "smoothLineScroll")
        
        addPropertyObservers()
    }
    
    private func addPropertyObservers() {
        $testMode
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value.rawValue, forKey: "testMode")
            }
            .store(in: &cancellables)
        
        $wordCount
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value.rawValue, forKey: "wordCount")
            }
            .store(in: &cancellables)
        
        $showKeyboard
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "showKeyboard")
            }
            .store(in: &cancellables)
        
        $layout
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value.rawValue, forKey: "keyboardLayout")
            }
            .store(in: &cancellables)
        
        $keyboardHeight
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "keyboardHeight")
            }
            .store(in: &cancellables)
        
        $keyboardOpacity
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "keyboardOpacity")
            }
            .store(in: &cancellables)
        
        $theme
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value.name, forKey: "selectedTheme")
            }
            .store(in: &cancellables)
        
        $showLiveWPM
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "showLiveWPM")
            }
            .store(in: &cancellables)
        
        $showLiveAccuracy
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "showLiveAccuracy")
            }
            .store(in: &cancellables)
        
        $caretStyle
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value.rawValue, forKey: "caretStyle")
            }
            .store(in: &cancellables)
        
        $language
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "language")
            }
            .store(in: &cancellables)
        
        $quoteLength
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value.rawValue, forKey: "quoteLength")
            }
            .store(in: &cancellables)
        
        $fontFamily
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "fontFamily")
            }
            .store(in: &cancellables)
        
        $fontSize
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "fontSize")
            }
            .store(in: &cancellables)
        
        $soundEnabled
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "soundEnabled")
            }
            .store(in: &cancellables)
        
        $playSoundOnClick
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "playSoundOnClick")
            }
            .store(in: &cancellables)
        
        $playSoundOnError
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "playSoundOnError")
            }
            .store(in: &cancellables)
        
        $soundVolume
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "soundVolume")
            }
            .store(in: &cancellables)
        
        $clickSoundPack
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "clickSoundPack")
            }
            .store(in: &cancellables)
        
        $smoothCursor
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "smoothCursor")
            }
            .store(in: &cancellables)
        
        $smoothLineScroll
            .dropFirst()
            .sink { value in
                UserDefaults.standard.set(value, forKey: "smoothLineScroll")
            }
            .store(in: &cancellables)
    }
}

extension Settings.Theme: Equatable {
    static func == (lhs: Settings.Theme, rhs: Settings.Theme) -> Bool {
        return lhs.name == rhs.name
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
