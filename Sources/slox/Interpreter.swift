

class Interpreter: ExprVisitor {
    typealias R = Any?
    init() {

    }

    @MainActor
    func interpret(expr: Expr) {
        do {
            let value: Any? = evaluate(expr)
            if let value_str = value as? String {
                print(stringify(value_str))
            }
        } catch let error as RuntimeError {
            Lox.runtimeError(error)
        }
    }

    public func visitLiteralExpr(_ expr: Expr.Literal) -> Any? {
        return expr.value;
    }

    public func visitGroupingExpr(_ expr: Expr.Grouping) -> Any? {
        return self.evaluate(expr.expression);
    }

    public func visitUnaryExpr(_ expr: Expr.Unary) -> Any? {
        let right: Any? = self.evaluate(expr.right)

        if expr.unary_operator.type == TokenType.MINUS {
            try? self.checkNumberOperand(expr.unary_operator, right)
            return -(right as! Double);
        } else if expr.unary_operator.type == TokenType.BANG {
            return !isTruthy(expr.right);
        }


        fatalError("Unreachable")
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
        return value as! String
    }


}