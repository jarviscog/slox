protocol ExprVisitor<R> {
  associatedtype R
  func visitAssignmentExpr(_ expr: Expr.Assignment) -> R;
  func visitBinaryExpr(_ expr: Expr.Binary) -> R;
  func visitGroupingExpr(_ expr: Expr.Grouping) -> R;
  func visitLiteralExpr(_ expr: Expr.Literal) -> R;
  func visitUnaryExpr(_ expr: Expr.Unary) -> R;
  func visitVariableExpr(_ expr: Expr.Variable) -> R;
}

class Expr {

    func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.R {
        fatalError()
    }
    class Assignment: Expr {
        init(name: Token, value: Expr) {
            self.name = name
            self.value = value
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.R {
            return visitor.visitAssignmentExpr(self);
        }
        let name: Token;
        let value: Expr;
    }

    class Binary: Expr {
        init(left: Expr , binary_operator: Token , right: Expr) {
            self.left = left
            self.binary_operator = binary_operator
            self.right = right
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.R {
            return visitor.visitBinaryExpr(self);
        }
        let left: Expr;
        let binary_operator: Token;
        let right: Expr;
    }

    class Grouping: Expr {
        init(expression: Expr) {
            self.expression = expression
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.R {
            return visitor.visitGroupingExpr(self);
        }
        let expression: Expr;
    }

    class Literal: Expr {
        init(value: Any?) {
            self.value = value
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.R {
            return visitor.visitLiteralExpr(self);
        }
        let value: Any?;
    }

    class Unary: Expr {
        init(unary_operator: Token , right: Expr) {
            self.unary_operator = unary_operator
            self.right = right
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.R {
            return visitor.visitUnaryExpr(self);
        }
        let unary_operator: Token;
        let right: Expr;
    }

    class Variable: Expr {
        init(name: Token) {
            self.name = name
        }

        override func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.R {
            return visitor.visitVariableExpr(self);
        }
        let name: Token;
    }

}
