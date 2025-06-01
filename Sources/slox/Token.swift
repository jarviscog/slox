
struct Token: @unchecked Sendable {

    var type: TokenType
    var lexeme: String
    var literal: Any?
    var line: Int 

    init(_ type: TokenType, _ lexeme: String, _ literal: Any?, _ line: Int) {
    		self.type = type
    		self.lexeme = lexeme
    		self.literal = literal
    		self.line = line

    }

    func toString() -> String {
        return "\(type) \(lexeme) \(literal ?? "")"

    }



}

