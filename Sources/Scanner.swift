
private extension TokenType {
    init?(keyword: String) {
        let keywords: [String: TokenType] = [
            "and": TokenType.AND,
            "class": TokenType.CLASS,
            "else": TokenType.ELSE,
            "false": TokenType.FALSE,
            "for": TokenType.FOR,
            "fun": TokenType.FUN,
            "if": TokenType.IF,
            "nil": TokenType.NIL,
            "or": TokenType.OR,
            "print": TokenType.PRINT,
            "return": TokenType.RETURN,
            "super": TokenType.SUPER,
            "this": TokenType.THIS,
            "true": TokenType.TRUE,
            "var": TokenType.VAR,
            "while": TokenType.WHILE
        ]
        
        guard let type = keywords[keyword]
            else { return nil }
        
        self = type
    }
}

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
        case "/":
            if(match("/") ) {
                // A comment that goes until the end of the line
                while (peek() != "\n" && !isAtEnd()) { advance() }
            } else {
                addToken(TokenType.SLASH)
            }
            break;
        case " ": break;
        case "\r": break;
        case "\t": break;
        case "\n": 
            self.line += 1 
            break;
        case "\"":
            string(); 
            break;

        default:
            if (isDigit(c)) {
                number()
            } else if (isAlpha(c)) {
                identifier()
            } else {
                Lox.error(line: line, message: "Unexpected Character")
            }
            break;

        }
    }

    func number() {
        while (isDigit(peek())) { advance() }

        // Look for a fractional part
        if (peek() == "." && isDigit(peekNext())) {
            advance();
            while(isDigit(peek())) {advance()}
        }

        let number_as_string = self.source[self.start..<self.current]
        let number = Double(number_as_string)
        addToken(TokenType.NUMBER, number)

    }

    func identifier() {
        while (isAlphaNumeric(peek())) {advance()}

        let text: String = String(self.source[start..<current])
        let type: TokenType = TokenType(keyword: text) ?? TokenType.IDENTIFIER
        addToken(type)
    }

    func peekNext() -> Character {
        let next: String.Index = self.source.index(after: self.current)
        if (next > self.source.endIndex) {return "\0"}
        return self.source[next]
    }

    @MainActor
    private func string() {
        while (peek() != "\"" && !isAtEnd()) {
            if (peek() == "\n") {
                self.line += 1
            }
            advance()
        }

        if (isAtEnd()) {
            Lox.error(line: line, message: "Unterminated String")
        }

        // The closing ".
        advance()

        // Trim the surrounding quotes
        let start_after = self.source.index(after: self.start)
        let current_before = self.source.index(before: self.current)
        let substring = self.source[start_after..<current_before]
        let value = String(substring)

        addToken(TokenType.STRING, value)
    }

    func peek() -> Character {
        if(isAtEnd()) {return "\0"}
        return self.source[self.current]
    }

    func isDigit(_ c: Character) -> Bool {
        return c >= "0" && c <= "9"
    }

    func isAlpha(_ c: Character) -> Bool {
        return (c >= "a" && c <= "z") ||
           (c >= "A" && c <= "Z") ||
            c == "_";
    }

    func isAlphaNumeric(_ c: Character) -> Bool {
        return ( isDigit(c) || isAlpha(c) )
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










