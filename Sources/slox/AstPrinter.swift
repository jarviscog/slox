
class AstPrinter: ExprVisitor {

    func print(expr: Expr) -> String {
        return expr.accept(visitor: self)
    }

    func visitAssignmentExpr(_ expr: Expr.Assignment) -> String {
        return String(describing: expr.name)
    }

    func visitBinaryExpr(_ expr: Expr.Binary) -> String {
        return self.parenthesize(expr.binary_operator.lexeme, expr.left, expr.right);
    }

    func visitGroupingExpr(_ expr: Expr.Grouping) -> String {
        return self.parenthesize("group", expr.expression);
    }

    func visitLiteralExpr(_ expr: Expr.Literal) -> String {
        if (expr.value == nil) { return "nil" };
        return String(describing: expr.value)
    }

    func visitUnaryExpr(_ expr: Expr.Unary) -> String {
        return parenthesize(expr.unary_operator.lexeme, expr.right);
    }

    func visitVariableExpr(_ expr: Expr.Variable) -> String {
        return String(describing: expr.name)
    }

    func visitCallExpr(_ expr: Expr.Call) throws -> String {
        return "call \(expr.callee) \(expr.arguments)"
    }

    func visitLogicalExpr(_ expr: Expr.Logical) -> String {
        return "\(expr.left) \(expr.logical_operator) \(expr.right)"
    }

  func parenthesize(_ name: String, _ exprs: Expr...) -> String {
    var ret_string: String = "";

    ret_string.append(contentsOf: "(")
    ret_string.append(contentsOf: name)
    for expr: Expr in exprs {
        ret_string.append(contentsOf: " ")
        ret_string.append(expr.accept(visitor: self))
        //builder.append(expr.accept(this));
    }
    ret_string.append(contentsOf: ")")

    return ret_string
  }

}