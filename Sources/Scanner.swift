
class Scanner {

    final var source: String
    final var tokens: Array<Token> = []
    var start: Int32 = 0;
    var current: Int32 = 0;
    var line: Int32 = 1;

    init(source: String) {
        self.source = source
    }

    func scanTokens() -> Array<Token> {

        while(!isAtEnd()) {
            start = current
            scanToken()
        }

        tokens.append(TokenType.EOF)

        return tokens

    }

    func scanToken() {

        let c: Character = advance()
        switch c {
            case "(": addToken(type: TokenType.LEFT_PAREN); break;
            case ")": addToken(type: TokenType.RIGHT_PAREN); break;
            case "{": addToken(type: TokenType.LEFT_BRACE); break;
            case "}": addToken(type: TokenType.RIGHT_BRACE); break;
            case ",": addToken(type: TokenType.COMMA); break;
            case ".": addToken(type: TokenType.DOT); break;
            case "-": addToken(type: TokenType.MINUS); break;
            case "+": addToken(type: TokenType.PLUS); break;
            case ";": addToken(type: TokenType.SEMICOLON); break;
            case "*": addToken(type: TokenType.STAR); break; 
        default:
            Lox.error(line: line, message: "Unexpected Character")

        }
    }

    func isAtEnd() -> Bool {
        return self.current >= source.count
    }

    func advance() -> Character {
        let charIndex = self.source.index(self.start, offsetBy: self.current)
        self.current += 1
        return self.source[charIndex]
    }

    func addToken(type: TokenType) {
        addToken(type: type, literal: nil)
    }

    func addToken(type: TokenType, literal: Any?) {
        let range = self.start..<self.current
        let text: String = source[range]
        tokens.append(
            Token(
                type: type,
                lexeme: text, 
                literal: literal, 
                line: line
            )
        )

    }

}

