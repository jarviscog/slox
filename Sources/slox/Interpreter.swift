

class Interpreter: ExprVisitor, StmtVisitor {
    typealias R = Any?
    init() {

    }
    var environment: Environment = Environment();

    @MainActor
    func interpret(statements: [Stmt]) {
        do {
            for statement in statements {
                execute(stmt: statement)
            }
        } catch let error as RuntimeError {
            Lox.runtimeError(error)
        }
    }

    public func visitLiteralExpr(_ expr: Expr.Literal) -> Any? {
        return expr.value;
    }

    public func visitLogicalExpr(_ expr: Expr.Logical) -> Any? {
        let left: Any? = evaluate(expr.left)

        if (expr.logical_operator.type == TokenType.OR) {
            if (isTruthy(expr.left)) { return left }

        } else {
            if (!isTruthy(expr.left)) { return left }
        }

        return evaluate(expr.right)
    }

    public func visitGroupingExpr(_ expr: Expr.Grouping) -> Any? {
        return self.evaluate(expr.expression);
    }

    public func visitUnaryExpr(_ expr: Expr.Unary) -> Any? {
        let right: Any? = self.evaluate(expr.right)

        if expr.unary_operator.type == TokenType.MINUS {
            try? self.checkNumberOperand(expr.unary_operator, right)
            return -(right as! Double)
        } else if expr.unary_operator.type == TokenType.BANG {
            return !isTruthy(expr.right)
        }
        fatalError("Unreachable")
    }

    public func visitVariableExpr(_ expr: Expr.Variable) -> Any? {
        // TODO Don't use '!'
        return try! environment.get(name: expr.name)!
    }

    public func visitAssignmentExpr(_ expr: Expr.Assignment) -> Any? {
        let value: Any? = evaluate(expr.value)
        try? environment.assign(name: expr.name, value: value)
        return value

    }

    public func checkNumberOperand(_ in_operator: Token, _ value: Any?) throws {
        if value is Double {
            return
        }
        throw RuntimeError(token: in_operator, message: "Operand Must be a number")
    }

    public func checkNumberOperands(_ in_operator: Token, _ left: Any?, _ right: Any?) throws {
        if left is Double && right is Double {return}
        throw RuntimeError(token: in_operator, message: "Operands must be numbers")
    }

    public func isTruthy(_ object: Any?) -> Bool {
        if (object == nil) { return false} 
        if let boolObject = object as? Bool {
            return boolObject
        }
        return true
    }

    private func evaluate(_ expr: Expr) -> Any? {
        return expr.accept(visitor: self)
    }

    private func execute(stmt: Stmt) {
        stmt.accept(visitor: self)
    }

    public func executeBlock(statements: [Stmt], environment: Environment) {
        let previous: Environment = self.environment
        do {
            self.environment = environment
            for statement in statements {
                execute(stmt: statement)
            }

        }
        self.environment = previous 
    }

    public func visitBlockStmt(_ stmt: Stmt.Block) -> Any? {
        executeBlock(statements: stmt.statements, environment: Environment(enclosing: environment))
        return nil
    }

    public func visitExpressionStmt(_ stmt: Stmt.Expression) -> Any? {
        evaluate(stmt.expression)
    }

    public func visitIfStmt(_ stmt: Stmt.If) -> Any? {
        if (isTruthy(evaluate(stmt.condition))) {
            execute(stmt: stmt.thenBranch)
        } else {
            execute(stmt: stmt.elseBranch)
        }
        return nil;
    }

    public func visitPrintStmt(_ stmt: Stmt.Print) -> Any? {
        let value = evaluate(stmt.expression);
        print(stringify(value));
        return nil
    }

    public func visitVarStmt(_ stmt: Stmt.Var) -> Any? {
        var value: Any? = nil;
        if (stmt.initializer != nil) {
            value = evaluate(stmt.initializer)
        }
        environment.define(name: stmt.name.lexeme, value: value);
        return nil;
    }

    public func visitWhileStmt(_ stmt: Stmt.While) -> Any? {
        while (isTruthy(evaluate(stmt.condition))) {
            execute(stmt: stmt.body)
        }
        return nil
    }

    public func visitBinaryExpr(_ expr: Expr.Binary) -> Any? {
        let left: Any? = self.evaluate(expr.left)
        let right: Any? = self.evaluate(expr.left)

        if expr.binary_operator.type  == TokenType.MINUS {
            try? checkNumberOperands(expr.binary_operator, left, right)
            return { (left as! Double) - (right as! Double)}
        } else if expr.binary_operator.type  == TokenType.PLUS {
            if left is Double && right is Double {
                return { (left as! Double) + (right as! Double)}
            } else if left is String && right is String {
                return { (left as! String) + (right as! String)}
            }

        } else if expr.binary_operator.type  == TokenType.SLASH {
            try? checkNumberOperands(expr.binary_operator, left, right)
            return { (left as! Double) / (right as! Double)}
        } else if expr.binary_operator.type  == TokenType.STAR {
            try? checkNumberOperands(expr.binary_operator, left, right)
            return { (left as! Double) * (right as! Double)}
        } else if expr.binary_operator.type  == TokenType.GREATER{
            try? checkNumberOperands(expr.binary_operator, left, right)
                return { (left as! Double) > (right as! Double)}
        } else if expr.binary_operator.type  == TokenType.GREATER_EQUAL{
            try? checkNumberOperands(expr.binary_operator, left, right)
                return { (left as! Double) >= (right as! Double)}
        } else if expr.binary_operator.type  == TokenType.LESS{
            try? checkNumberOperands(expr.binary_operator, left, right)
                return { (left as! Double) < (right as! Double)}
        } else if expr.binary_operator.type  == TokenType.LESS_EQUAL{
            try? checkNumberOperands(expr.binary_operator, left, right)
                return { (left as! Double) <= (right as! Double)}
        } else if expr.binary_operator.type  == TokenType.BANG_EQUAL{
            return !isEqual(left, right);
        } else if expr.binary_operator.type  == TokenType.EQUAL_EQUAL{
            return isEqual(left, right);
        }
        fatalError("Unreachable")
    }

    public func isEqual(_ left: Any?, _ right: Any?) -> Bool {
        if left == nil && right == nil {return true}
        if left == nil { return false }

        if let lHash = left as? AnyHashable, let rHash = right as? AnyHashable {
            return lHash == rHash
        }

        if let lObject = left as? AnyObject, let rObject = right as? AnyObject {
            return lObject === rObject
        }
        return false
    }

    public func stringify(_ value: Any?) -> String {
        if value == nil { return "nil" }

        if (value is Double) {
            return String(format: "%f", value as! Double)
        }
        return String(describing: value)
    }


}