protocol ExprVisitor<R> {
  associatedtype R
  func visitBinaryExpr(_ expr: Expr.Binary) -> R;
  func visitGroupingExpr(_ expr: Expr.Grouping) -> R;
  func visitLiteralExpr(_ expr: Expr.Literal) -> R;
  func visitUnaryExpr(_ expr: Expr.Unary) -> R;
}

class Expr {

    func accept<V: ExprVisitor, R>(visitor: V) -> R where R == V.R {
        fatalError()
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

}
