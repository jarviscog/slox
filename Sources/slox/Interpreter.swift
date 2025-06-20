

class Interpreter: ExprVisitor, StmtVisitor {
    final var globals: Environment = Environment()
    private var environment: Environment
    typealias R = Any?
    init() {
        self.environment = globals;

        self.globals.define(name: "clock", value: Clock())
    }

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

    public func visitFunctionStmt(_ stmt: Stmt.Function) -> Any? {
        let function: LoxFunction = LoxFunction(declaration: stmt, closure: environment)
        environment.define(name: stmt.name.lexeme, value: function)
        return nil
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

    public func visitReturnStmt(_ stmt: Stmt.Return) throws -> Any? {
        let value: LiteralValue = try evaluate(stmt.value) as! LiteralValue
        throw Return(value)
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
        let left_optional: Any? = self.evaluate(expr.left)
        let right_optional: Any? = self.evaluate(expr.right)

        if let left = left_optional{
            if let right = right_optional {

                switch expr.binary_operator.type {
                    case .PLUS:
                        if left is Double && right is Double {
                            print("Visiting plus")
                            print("left: \(left)")
                            print("right: \(right)")
                            let ret_val = (left as! Double) + (right as! Double)
                            print("ret: \(ret_val)")
                            return ret_val
                        } else if left is String && right is String {
                            return (left as! String) + (right as! String)
                        }
                    case .MINUS:
                        try? checkNumberOperands(expr.binary_operator, left, right)
                        return (left as! Double) - (right as! Double)
                    case .SLASH:
                        try? checkNumberOperands(expr.binary_operator, left, right)
                        return (left as! Double) / (right as! Double)
                    case .STAR:
                        try? checkNumberOperands(expr.binary_operator, left, right)
                        return (left as! Double) * (right as! Double)
                    case .GREATER:
                        try? checkNumberOperands(expr.binary_operator, left, right)
                        return (left as! Double) > (right as! Double)
                    case .GREATER_EQUAL:
                        try? checkNumberOperands(expr.binary_operator, left, right)
                        return (left as! Double) >= (right as! Double)
                    case .LESS:
                        try? checkNumberOperands(expr.binary_operator, left, right)
                        return { (left as! Double) < (right as! Double)}
                    case .LESS_EQUAL:
                        try? checkNumberOperands(expr.binary_operator, left, right)
                        return { (left as! Double) <= (right as! Double)}
                    case .BANG_EQUAL:
                        return !isEqual(left, right);
                    case .EQUAL_EQUAL:
                        return isEqual(left, right);
                    default: break
                }

            }
        }
        fatalError("Unreachable")
    }

    public func visitCallExpr(_ expr: Expr.Call) throws -> Any? {
        let callee: Any? = evaluate(expr.callee)

        var arguments: [Any?] = []
        for argument in expr.arguments {
            arguments.append(evaluate(argument))
        }

        if let callee_is_string = callee as? String {
            // TODO Definitely need to bug test this (Does it cast properly?)
            let function: LoxCallable = callee as! LoxCallable
            if (arguments.count != function.arity()) {
                // TODO I don't really want to mark this method as throws, but I'm forced to because of this
                //   Figure out a way to make this non-throws
                throw RuntimeError(token: expr.paren, message: "Expected \(function.arity()) arguments got \(arguments.count).")
            }
            return function.call(self, arguments)
        } else {
            throw RuntimeError(token: expr.paren, message: "Can only call functions and classes")
        }

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
        if let unwraped_value: Any = value {
            if (unwraped_value is Double) {
                return String(format: "%f", value as! Double)
            }
            return String(describing: unwraped_value)
        }


        return String(describing: value)
    }


}