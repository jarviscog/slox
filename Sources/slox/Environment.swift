
class Environment {
    final let enclosing: Environment?

    private final var values: [String: Any?];
    init() {
        values = [String: Any?]();
        self.enclosing = nil;
    }

    init(enclosing: Environment) {
        values = [String: Any?]();
        self.enclosing = enclosing;
    }

    public func define(name: String, value: Any?) {
        values[name] = value
    }

    public func assign(name: Token, value: Any?) throws {
        if let curr_value = values[name.lexeme] {
            values[name.lexeme] = value
            return
        }

        if let env = enclosing {
            try env.assign(name: name, value: value)
            return
        }

        throw RuntimeError(token: name, message: "Undefined Variable '\(name.lexeme)'.")
    }

    public func get(name: Token) throws -> Any? {
        if let value = values[name.lexeme] {
            return value
        }

        if let env = enclosing {
            return try env.get(name: name)
        }

        throw RuntimeError(token: name, message:  "Undefined Variable \(name.lexeme).")
    }
}