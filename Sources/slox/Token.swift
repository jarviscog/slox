
class Token {

    final var type: TokenType
    final var lexeme: String
    final var literal: Any?
    final var line: Int 

    init(type: TokenType, lexeme: String, literal: Any?, line: Int) {
    		self.type = type
    		self.lexeme = lexeme
    		self.literal = literal
    		self.line = line

    }

    func toString() -> String {
        return "\(type) \(lexeme) \(literal ?? "")"

    }



}

