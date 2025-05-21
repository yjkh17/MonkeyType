import Foundation

class Settings: ObservableObject {
    enum TestMode: String, CaseIterable {
        case time
        case words
        case quote
        case zen
    }
    
    enum WordCount: Int, CaseIterable {
        case ten = 10
        case twenty = 20
        case fifty = 50
        case hundred = 100
        
        var description: String {
            "\(self.rawValue)"
        }
    }
    
    @Published var testMode: TestMode = .time
    @Published var wordCount: WordCount = .twenty
    @Published var language: String = "english"
    @Published var showLiveWPM: Bool = true
    @Published var showLiveAccuracy: Bool = true
    @Published var fontFamily: String = "JetBrains Mono"
    @Published var fontSize: Int = 16
}