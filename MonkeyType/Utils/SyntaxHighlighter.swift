import SwiftUI

class SyntaxHighlighter {
    static func highlight(_ text: String, language: String) -> AttributedString {
        var attributedString = AttributedString(text)
        
        // Basic syntax highlighting patterns
        let patterns: [(pattern: String, color: Color)] = [
            // Keywords
            ("\\b(func|var|let|if|else|for|while|return|class|struct|enum|import|switch|case|break|continue|guard|defer|in|init|self|super|true|false|nil)\\b", .purple),
            
            // Function calls
            ("\\b[a-zA-Z_][a-zA-Z0-9_]*(?=\\()", .blue),
            
            // Numbers
            ("\\b\\d+\\.?\\d*\\b", .orange),
            
            // Strings
            ("\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", .green),
            
            // Comments
            ("//[^\n]*", .gray),
            
            // Types
            ("\\b(String|Int|Double|Bool|Array|Dictionary|Set|Any|Void)\\b", .red)
        ]
        
        // Apply highlighting
        for (pattern, color) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let range = NSRange(text.startIndex..., in: text)
                let matches = regex.matches(in: text, options: [], range: range)
                
                for match in matches {
                    if let range = Range(match.range, in: text) {
                        attributedString[range].foregroundColor = color
                    }
                }
            } catch {
                print("Regex error: \(error)")
            }
        }
        
        return attributedString
    }
}