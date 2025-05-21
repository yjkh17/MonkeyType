import SwiftUI

class SyntaxHighlighter {
    static func highlight(_ text: String, language: String) -> AttributedString {
        let attributedString = NSMutableAttributedString(string: text)
        
        // Get language-specific patterns
        let patterns = getPatternsForLanguage(language)
        
        // Apply highlighting
        for (pattern, color) in patterns {
            do {
                let regex = try NSRegularExpression(pattern: pattern, options: [])
                let range = NSRange(text.startIndex..., in: text)
                let matches = regex.matches(in: text, options: [], range: range)
                
                for match in matches {
                    attributedString.addAttribute(.foregroundColor, value: color, range: match.range)
                }
            } catch {
                print("Regex error: \(error)")
            }
        }
        
        return AttributedString(attributedString)
    }
    
    private static func getPatternsForLanguage(_ language: String) -> [(pattern: String, color: NSColor)] {
        switch language {
        case "code_python":
            return [
                // Keywords
                ("\\b(def|class|if|else|elif|for|while|return|import|from|as|try|except|finally|with|in|is|not|and|or|True|False|None|async|await|lambda)\\b", .systemPurple),
                // Function calls
                ("\\b[a-zA-Z_][a-zA-Z0-9_]*(?=\\()", .systemBlue),
                // Numbers
                ("\\b\\d+\\.?\\d*\\b", .systemOrange),
                // Strings
                ("\"\"\"[^\"\"\"]*\"\"\"|'''[^''']*'''|\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"|'[^'\\\\]*(?:\\\\.[^'\\\\]*)*'", .systemGreen),
                // Comments
                ("#[^\n]*", .systemGray),
                // Types
                ("\\b(str|int|float|bool|list|dict|set|tuple)\\b", .systemRed),
                // Special
                ("\\b(self|cls)\\b", .systemTeal),
                // Decorators
                ("@[a-zA-Z_][a-zA-Z0-9_]*", .systemYellow)
            ]
            
        case "code_javascript":
            return [
                // Keywords
                ("\\b(function|const|let|var|if|else|for|while|return|class|extends|new|this|super|import|export|default|null|undefined|true|false|async|await|try|catch|finally)\\b", .systemPurple),
                // Function calls
                ("\\b[a-zA-Z_][a-zA-Z0-9_]*(?=\\()", .systemBlue),
                // Numbers
                ("\\b\\d+\\.?\\d*\\b", .systemOrange),
                // Strings
                ("`[^`]*`|'[^']*'|\"[^\"]*\"", .systemGreen),
                // Comments
                ("//[^\n]*|/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/", .systemGray),
                // Types
                ("\\b(String|Number|Boolean|Array|Object|Promise)\\b", .systemRed),
                // Special
                ("\\b(console|document|window)\\b", .systemTeal),
                // Template literals
                ("\\${[^}]*}", .systemYellow)
            ]
            
        case "code_rust":
            return [
                // Keywords
                ("\\b(fn|let|mut|const|if|else|for|while|return|struct|enum|impl|trait|pub|use|mod|match|as|in|unsafe|where|Self|self|async|await|move)\\b", .systemPurple),
                // Function calls
                ("\\b[a-zA-Z_][a-zA-Z0-9_]*(?=\\(|!\\()", .systemBlue),
                // Numbers
                ("\\b\\d+\\.?\\d*\\b", .systemOrange),
                // Strings
                ("\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", .systemGreen),
                // Comments
                ("//[^\n]*|/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/", .systemGray),
                // Types
                ("\\b(String|i32|u32|f64|bool|Vec|Option|Result)\\b", .systemRed),
                // Lifetimes
                ("'[a-zA-Z_][a-zA-Z0-9_]*", .systemYellow),
                // Macros
                ("\\b[a-zA-Z_][a-zA-Z0-9_]*!", .systemTeal)
            ]
            
        case "code_go":
            return [
                // Keywords
                ("\\b(func|var|const|if|else|for|range|return|struct|interface|type|package|import|defer|go|chan|select|case|break|continue|map|make|new)\\b", .systemPurple),
                // Function calls
                ("\\b[a-zA-Z_][a-zA-Z0-9_]*(?=\\()", .systemBlue),
                // Numbers
                ("\\b\\d+\\.?\\d*\\b", .systemOrange),
                // Strings
                ("`[^`]*`|\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", .systemGreen),
                // Comments
                ("//[^\n]*|/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/", .systemGray),
                // Types
                ("\\b(string|int|float64|bool|error|interface{})\\b", .systemRed),
                // Special
                ("\\b(nil|iota)\\b", .systemTeal),
                // Rune literals
                ("'[^']*'", .systemYellow)
            ]
            
        case "code_cpp":
            return [
                // Keywords
                ("\\b(class|struct|enum|union|namespace|template|typename|public|private|protected|virtual|static|const|auto|if|else|for|while|do|switch|case|break|continue|return|new|delete|nullptr|true|false)\\b", .systemPurple),
                // Function calls
                ("\\b[a-zA-Z_][a-zA-Z0-9_]*(?=\\()", .systemBlue),
                // Numbers
                ("\\b\\d+\\.?\\d*\\b", .systemOrange),
                // Strings
                ("\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", .systemGreen),
                // Comments
                ("//[^\n]*|/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/", .systemGray),
                // Types
                ("\\b(int|float|double|char|bool|void|string|vector|map|set)\\b", .systemRed)
            ]
            
        case "code_java":
            return [
                // Keywords
                ("\\b(class|interface|enum|extends|implements|new|instanceof|if|else|for|while|do|switch|case|break|continue|return|public|private|protected|static|final|abstract|try|catch|finally|throw|throws|null|true|false)\\b", .systemPurple),
                // Function calls
                ("\\b[a-zA-Z_][a-zA-Z0-9_]*(?=\\()", .systemBlue),
                // Numbers
                ("\\b\\d+\\.?\\d*\\b", .systemOrange),
                // Strings
                ("\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", .systemGreen),
                // Comments
                ("//[^\n]*|/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/", .systemGray),
                // Types
                ("\\b(String|Integer|Double|Boolean|Array|List|Map|Set|void)\\b", .systemRed)
            ]
            
        case "code_typescript":
            return [
                // TypeScript specific keywords
                ("\\b(interface|type|enum|namespace|implements|declare|abstract|private|protected|public|readonly|as|is|keyof|typeof|never|unknown|any)\\b", .systemPurple),
                // JavaScript keywords (shared)
                ("\\b(function|const|let|var|if|else|for|while|return|class|extends|new|this|super|import|export|default|null|undefined|true|false|async|await|try|catch|finally)\\b", .systemPurple),
                // Function calls
                ("\\b[a-zA-Z_][a-zA-Z0-9_]*(?=\\()", .systemBlue),
                // Numbers
                ("\\b\\d+\\.?\\d*\\b", .systemOrange),
                // Strings
                ("`[^`]*`|'[^']*'|\"[^\"]*\"", .systemGreen),
                // Comments
                ("//[^\n]*|/\\*[^*]*\\*+(?:[^/*][^*]*\\*+)*/", .systemGray),
                // Types
                ("\\b(string|number|boolean|void|null|undefined)\\b", .systemRed),
                // Type annotations
                (":[^=,}]+", .systemTeal),
                // Generics
                ("<[^>]+>", .systemYellow),
                // Decorators
                ("@[a-zA-Z_][a-zA-Z0-9_]*", .systemYellow),
                // Template literals
                ("\\${[^}]*}", .systemYellow)
            ]
            
        default: // Generic code highlighting
            return [
                // Keywords
                ("\\b(func|var|let|if|else|for|while|return|class|struct|enum|import|switch|case|break|continue|guard|defer|in|init|self|super|true|false|nil)\\b", .systemPurple),
                // Function calls
                ("\\b[a-zA-Z_][a-zA-Z0-9_]*(?=\\()", .systemBlue),
                // Numbers
                ("\\b\\d+\\.?\\d*\\b", .systemOrange),
                // Strings
                ("\"[^\"\\\\]*(?:\\\\.[^\"\\\\]*)*\"", .systemGreen),
                // Comments
                ("//[^\n]*", .systemGray),
                // Types
                ("\\b(String|Int|Double|Bool|Array|Dictionary|Set|Any|Void)\\b", .systemRed)
            ]
        }
    }
}
