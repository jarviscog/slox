
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
            if match(TokenType.FUN) { return try function("function") }
            if match(TokenType.VAR) { return try varDeclaration() }
            return try statement()

        } catch let error as ParseError {
            synchronize()
            return nil;
        }

    }

    private func statement() throws -> Stmt {
        if match(TokenType.FOR) { return try forStatement() };
        if match(TokenType.IF) { return try ifStatement() };
        if match(TokenType.PRINT) { return try printStatement() };
        if match(TokenType.RETURN) { return try returnStatement() };
        if match(TokenType.WHILE) { return try whileStatement() };
        if match(TokenType.LEFT_BRACE) { return Stmt.Block(statements: try block()) };

        return try expressionStatement();
    }
    
    private func forStatement() throws -> Stmt {
        consume(TokenType.LEFT_PAREN, "Expect '(' after for.")

        let initializer: Stmt?
        if match(TokenType.SEMICOLON) {
            initializer = nil;
        } else if match(TokenType.VAR) {
            initializer = try varDeclaration()
        } else {
            initializer = try expressionStatement()
        }

        var condition: Expr? = nil;
        if !check(TokenType.SEMICOLON) {
            condition = try expression()
        }
        consume(TokenType.SEMICOLON, "Expect ';' after loop condition")

        var increment: Expr? = nil;
        if !check(TokenType.RIGHT_PAREN) {
            increment = try expression()
        }
        consume(TokenType.RIGHT_PAREN, "Expect ')' after for clauses")
        var body: Stmt = try statement()

        if (increment != nil) {
            body = Stmt.Block(statements: [body, Stmt.Expression(expression: increment!)])
        }

        if (condition == nil) {
            condition = Expr.Literal(value: LiteralValue.bool(true))
        }
        body = Stmt.While(condition: condition!, body: body)

        if let initializer = initializer {
            body = Stmt.Block(statements: [initializer, body])
        }

        return body
    }

    private func ifStatement() throws -> Stmt {
        consume(TokenType.LEFT_PAREN, "Expect '(' after if")
        let condition: Expr = try expression()
        consume(TokenType.RIGHT_PAREN, "Expect ')' after if condition")
        let thenBranch: Stmt = try statement()
        var elseBranch: Stmt? = nil;
        if (match(TokenType.ELSE)) {
            elseBranch = try statement()
        }
        return Stmt.If(condition: condition, thenBranch: thenBranch, elseBranch: elseBranch!)
    }

    private func printStatement() throws -> Stmt {
        let value: Expr = try expression();
        consume(TokenType.SEMICOLON, "Expect ';' after value.")
        return Stmt.Print(expression: value)
    }

    private func returnStatement() throws -> Stmt {
        let keyword: Token = previous()
        var value: Expr? = nil
        if (!check(TokenType.SEMICOLON)) {
            value = try expression()
        }
        consume(TokenType.SEMICOLON, "Expect ';' after return value")
        // TODO don't use '!'
        return Stmt.Return(keyword: keyword, value: value!)
    }

    private func varDeclaration() throws -> Stmt {
        let tokenName = consume(TokenType.IDENTIFIER, "Expect Variable Name");
        var initializer: Expr = Expr.Literal(value: LiteralValue.nil);
        if match(TokenType.EQUAL) {
            initializer = try expression();
        }

        consume(TokenType.SEMICOLON, "Expect ';' after variable declaration")
        return Stmt.Var(name: tokenName, initializer: initializer)

    }

    private func whileStatement() throws -> Stmt {
        consume(TokenType.LEFT_PAREN, "Expect '(' after 'while'.")
        let condition: Expr = try expression()
        consume(TokenType.LEFT_PAREN, "Expect ')' after condition.")
        let body: Stmt = try statement()
        return Stmt.While(condition: condition, body: body)
    }

    private func expressionStatement() throws -> Stmt {
        let value: Expr = try expression();
        consume(TokenType.SEMICOLON, "Expect ';' after value.")
        return Stmt.Expression(expression: value)
    }

    private func function(_ kind: String) throws -> Stmt.Function {
        let name: Token = consume(TokenType.IDENTIFIER, "Expect \(kind) name.")
        consume(TokenType.LEFT_PAREN, "Expect '(' after \(kind) name.")
        var params: [Token] = []
        if !check(TokenType.RIGHT_PAREN) {
            repeat {
                if params.count >= 255 {
                    error(peek(), "Cannot have more than 255 parameters")
                }
                params.append(consume(TokenType.IDENTIFIER, "Expect parameter name"))

            } while match(TokenType.COMMA)

        }
        consume(TokenType.RIGHT_PAREN, "Expect '(' after parameters.")
        consume(TokenType.LEFT_BRACE, "Expect '{' before \(kind) body.")
        let body: [Stmt] = try block()
        return Stmt.Function(name: name, params: params, body: body)
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
        let expr: Expr = try or()

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

    private func or() throws -> Expr {
        var expr: Expr = try and()

        while match(TokenType.OR) {
            let logical_operator: Token = previous()
            let right: Expr = try and()
            expr = Expr.Logical(left: expr, logical_operator: logical_operator, right: right)
        }
        return expr
    }

    private func and() throws -> Expr {
        var expr: Expr = try equality();
        while match(TokenType.AND) {
            let logical_operator: Token = previous()
            let right: Expr = try equality()
            expr = Expr.Logical(left: expr, logical_operator: logical_operator, right: right)
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

        return try call()
    }

    private func call() throws -> Expr {
        var expr: Expr = try primary()

        while (true) {
            if match(TokenType.LEFT_PAREN) {
                expr = try finishCall(callee: expr)
            } else {
                break
            }
        }
        return expr
    }

    private func finishCall(callee: Expr) throws -> Expr {

        var arguments: [Expr] = []
        if (!check(TokenType.RIGHT_PAREN)) {
            repeat {
                if arguments.count >= 255 {
                    error(peek(), "Can't have more than 255 arguments in a function call")
                }
                arguments.append(try expression())
            } while match(TokenType.COMMA)
        }
        let paren: Token = consume(TokenType.RIGHT_PAREN, "Expect ')' after call arguments.")
        return Expr.Call(callee: callee, paren: paren, arguments: arguments)

    }

    private func primary() throws -> Expr {
        if self.match(TokenType.FALSE) { return Expr.Literal(value: LiteralValue.bool(false)) }
        if self.match(TokenType.TRUE) { return Expr.Literal(value: LiteralValue.bool(true)) }
        if self.match(TokenType.NIL) { return Expr.Literal(value: LiteralValue.nil) }

        if (self.match(TokenType.NUMBER )) {
            return Expr.Literal(value: LiteralValue.number(self.previous().literal as! Double))
        }
        if (self.match(TokenType.STRING )) {
            return Expr.Literal(value: LiteralValue.string(self.previous().literal as! String))
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