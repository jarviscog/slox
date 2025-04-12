
class Scanner {

    private final var source: String
    private final var tokens: Array<Token> = []
    private var start: String.Index
    private var current: String.Index
    private var line: Int = 1;

    init(source: String) {
        self.source = source
        self.start = source.startIndex
        self.current = source.startIndex
    }

    @MainActor
    func scanTokens() -> Array<Token> {

        while(!isAtEnd()) {
            start = current
            scanToken()
        }

        tokens.append(
            Token(
                type: TokenType.EOF,
                lexeme: "",
                literal: nil,
                line: line
            )
        )

        return tokens

    }

    @MainActor
    func scanToken() {

        let c: Character = advance()
        switch c {
        case "(": addToken(TokenType.LEFT_PAREN); break;
        case ")": addToken(TokenType.RIGHT_PAREN); break;
        case "{": addToken(TokenType.LEFT_BRACE); break;
        case "}": addToken(TokenType.RIGHT_BRACE); break;
        case ",": addToken(TokenType.COMMA); break;
        case ".": addToken(TokenType.DOT); break;
        case "-": addToken(TokenType.MINUS); break;
        case "+": addToken(TokenType.PLUS); break;
        case ";": addToken(TokenType.SEMICOLON); break;
        case "*": addToken(TokenType.STAR); break; 
        case "!":
            addToken(match("=") ? TokenType.BANG_EQUAL : TokenType.BANG)
            break;
        case "=":
            addToken(match("=") ? TokenType.EQUAL_EQUAL : TokenType.EQUAL)
            break;
        case "<":
            addToken(match("=") ? TokenType.LESS_EQUAL : TokenType.LESS)
            break;
        case ">":
            addToken(match("=") ? TokenType.GREATER_EQUAL : TokenType.GREATER)
            break;
        default:
            Lox.error(line: line, message: "Unexpected Character")
            break

        }
    }

    func match(_ expected: Character) -> Bool {
        if (isAtEnd()) { return false }
        if (self.source[self.current] != expected) { return false }
        self.current = self.source.index(after: self.current)
        return true;

    }

    func isAtEnd() -> Bool {
        return current >= source.endIndex
    }

    @discardableResult
    func advance() -> Character {
        let char = self.source[self.current]
        self.current = self.source.index(after: self.current)
        return char
    }

    func addToken(_ type: TokenType) {
        addToken(type, nil)
    }

    func addToken(_ type: TokenType, _ literal: Any?) {

         //if let index = source.index(of: "cd") {
             //let substring = source[..<index]   // ab
             //let string = String(substring)
             //print(string)  // "ab\n"
         //}

        let substring = self.source[self.start..<self.current]
        let text = String(substring)
        // String text = source.substring(start, current);
        print("Adding token:")
        print(text)

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










