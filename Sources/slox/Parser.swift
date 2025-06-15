
@MainActor
class Parser {

    private struct ParseError: Error {};
    let tokens: Array<Token>;
    var current: Int = 0;
    init(tokens: Array<Token>) {
        self.tokens = tokens;
    }

    func parse() throws -> [Stmt] {
        var statements: [Stmt] = [];
        while !self.isAtEnd() {
            // TODO Don't use '!'
            try statements.append(declaration()!)
        }
        return statements
    }

    private func expression() throws -> Expr {
        return try assignment()
    }

    private func declaration() throws -> Stmt? {
        
        do {
            if match(TokenType.VAR) { return try varDeclaration() }
            return try statement()

        } catch let error as ParseError {
            synchronize()
            return nil;
        }

    }

    private func statement() throws -> Stmt {
        if match(TokenType.PRINT) { return try printStatement() };
        if match(TokenType.LEFT_BRACE) { return Stmt.Block(statements: try block()) };

        return try expressionStatement();
    }

    private func printStatement() throws -> Stmt {
        let value: Expr = try expression();
        consume(TokenType.SEMICOLON, "Expect ';' after value.")
        return Stmt.Print(expression: value)
    }

    private func varDeclaration() throws -> Stmt {
        let tokenName = consume(TokenType.IDENTIFIER, "Expect Variable Name");
        var initializer: Expr = Expr.Literal(value: nil);
        if match(TokenType.EQUAL) {
            initializer = try expression();
        }

        consume(TokenType.SEMICOLON, "Expect ';' after variable declaration")
        return Stmt.Var(name: tokenName, initializer: initializer)

    }

    private func expressionStatement() throws -> Stmt {
        let value: Expr = try expression();
        consume(TokenType.SEMICOLON, "Expect ';' after value.")
        return Stmt.Expression(expression: value)
    }

    private func block() throws -> [Stmt] {
        var statements: [Stmt] = [Stmt]()

        while(!check(TokenType.RIGHT_BRACE) && !isAtEnd()) {

            // TODO: Is this the right way to append? 
            //  Should I append an empty statement if declaration returns nil? 
            if let stmt = try declaration() {
                statements.append(stmt)
            }
        }

        consume(TokenType.RIGHT_BRACE, "Expect '}' at end.")
        return statements
    }

    private func assignment() throws -> Expr {
        let expr: Expr = try equality();

        if match(TokenType.EQUAL) {
            let equals: Token = previous();
            let value: Expr = try assignment();
            if ( type(of: expr) == Expr.Variable.self) {
                let name: Token = (expr as! Expr.Variable).name
                return Expr.Assignment(name: name, value: value)
            }

            error(equals, "Invalid Assignment target")

        }
        return expr
    }

    

    private func equality() throws -> Expr {
        var expr = try self.comparison()

        while (self.match(TokenType.BANG_EQUAL, TokenType.EQUAL_EQUAL)) {
            let binary_operator: Token = self.previous()
            let right: Expr = try self.comparison()
            expr = Expr.Binary(left: expr, binary_operator: binary_operator, right: right)
        }
        return expr;
    }

    private func comparison() throws -> Expr {
        var expr: Expr = try self.term();

        while self.match(TokenType.GREATER, TokenType.GREATER_EQUAL, TokenType.LESS, TokenType.LESS_EQUAL) {
            let binary_operator: Token = self.previous()
            let right: Expr = try self.term();
            expr = Expr.Binary(left: expr, binary_operator: binary_operator, right: right)
        }
        return expr;
    }

    private func term() throws -> Expr {
        var expr: Expr = try self.factor();

        while self.match(TokenType.PLUS, TokenType.MINUS) {
            let binary_operator: Token = self.previous();
            let right: Expr = try self.factor();
            expr = Expr.Binary(left: expr, binary_operator: binary_operator, right: right);
        }
        return expr;
    }

    private func factor() throws -> Expr {
        var expr: Expr = try self.unary();

        while self.match(TokenType.PLUS, TokenType.MINUS) {
            let binary_operator: Token = self.previous();
            let right: Expr = try self.unary();
            expr = Expr.Binary(left: expr, binary_operator: binary_operator, right: right);
        }
        return expr;
    }

    private func unary() throws -> Expr {
        if self.match(TokenType.BANG, TokenType.MINUS) {
            let unary_operator: Token = self.previous();
            let right: Expr = try self.unary();
            return Expr.Unary(unary_operator: unary_operator, right: right);
        }
        return try self.primary()
    }

    private func primary() throws -> Expr {
        if self.match(TokenType.FALSE) { return Expr.Literal(value: TokenType.FALSE) }
        if self.match(TokenType.TRUE) { return Expr.Literal(value: TokenType.TRUE) }
        if self.match(TokenType.NIL) { return Expr.Literal(value: TokenType.NIL) }

        if (self.match(TokenType.NUMBER, TokenType.STRING)) {
            return Expr.Literal(value: self.previous().literal)
        }
        if (self.match(TokenType.IDENTIFIER)) {
            return Expr.Variable(name: previous());
        }
        if (self.match(TokenType.LEFT_PAREN)) {
            let expr: Expr = try self.expression();
            self.consume(TokenType.RIGHT_PAREN, "Expecting ')' after expression")
            return Expr.Grouping(expression: expr)
        }

        throw error(self.peek(), "Expect Expression")
    }

    private func match(_ types: TokenType...) -> Bool {
        for type: TokenType in types {
            if(self.check(type)) {
                self.advance()
                return true
            }
        }
        return false
    }

    @discardableResult
    private func consume(_ type: TokenType, _ message: String) -> Token {
        if self.check(type) { return self.advance(); }
        fatalError(message)
    }

    private func check(_ type: TokenType) -> Bool {
        if (self.isAtEnd()) { return false }
        return self.peek().type == type;
    }

    @discardableResult
    private func advance() -> Token {
        if !self.isAtEnd() { self.current += 1; }
        return self.previous();
    }

    private func isAtEnd() -> Bool {
        return self.peek().type == TokenType.EOF;
    }

    private func peek() -> Token {
        return self.tokens[self.current];
    }

    private func previous() -> Token {
        return self.tokens[self.current - 1];
    }

    private func error(_ token: Token, _ message: String) -> ParseError {
        Lox.error(token: token, message: message);
        return ParseError();

    }

    private func synchronize() {
        self.advance();
        while (!isAtEnd()) {
            if (self.previous().type == TokenType.SEMICOLON) {return} ;
            let next_type = self.peek().type;
            if (next_type == TokenType.CLASS) { }
            else if (next_type == TokenType.FUN) { }
            else if (next_type == TokenType.VAR) { }
            else if (next_type == TokenType.FOR) { }
            else if (next_type == TokenType.IF) { }
            else if (next_type == TokenType.WHILE) { }
            else if (next_type == TokenType.PRINT) { }
            if (next_type == TokenType.RETURN) { return }
        }
        self.advance();
    }
}