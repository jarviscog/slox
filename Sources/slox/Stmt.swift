protocol StmtVisitor<R> {
  associatedtype R
  func visitBlockStmt(_ stmt: Stmt.Block) -> R;
  func visitExpressionStmt(_ stmt: Stmt.Expression) -> R;
  func visitPrintStmt(_ stmt: Stmt.Print) -> R;
  func visitVarStmt(_ stmt: Stmt.Var) -> R;
}

class Stmt {

    func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.R {
        fatalError()
    }
    class Block: Stmt {
        init(statements: [Stmt]) {
            self.statements = statements
        }

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.R {
            return visitor.visitBlockStmt(self);
        }
        let statements: [Stmt];
    }

    class Expression: Stmt {
        init(expression: Expr) {
            self.expression = expression
        }

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.R {
            return visitor.visitExpressionStmt(self);
        }
        let expression: Expr;
    }

    class Print: Stmt {
        init(expression: Expr) {
            self.expression = expression
        }

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.R {
            return visitor.visitPrintStmt(self);
        }
        let expression: Expr;
    }

    class Var: Stmt {
        init(name: Token, initializer: Expr) {
            self.name = name
            self.initializer = initializer
        }

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.R {
            return visitor.visitVarStmt(self);
        }
        let name: Token;
        let initializer: Expr;
    }

}
