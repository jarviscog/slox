protocol StmtVisitor<R> {
  associatedtype R
  func visitBlockStmt(_ stmt: Stmt.Block) -> R;
  func visitExpressionStmt(_ stmt: Stmt.Expression) -> R;
  func visitIfStmt(_ stmt: Stmt.If) -> R;
  func visitPrintStmt(_ stmt: Stmt.Print) -> R;
  func visitVarStmt(_ stmt: Stmt.Var) -> R;
  func visitWhileStmt(_ stmt: Stmt.While) -> R;
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

    class If: Stmt {
        init(condition: Expr, thenBranch: Stmt, elseBranch: Stmt) {
            self.condition = condition
            self.thenBranch = thenBranch
            self.elseBranch = elseBranch
        }

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.R {
            return visitor.visitIfStmt(self);
        }
        let condition: Expr;
        let thenBranch: Stmt;
        let elseBranch: Stmt;
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

    class While: Stmt {
        init(condition: Expr, body: Stmt) {
            self.condition = condition
            self.body = body
        }

        override func accept<V: StmtVisitor, R>(visitor: V) -> R where R == V.R {
            return visitor.visitWhileStmt(self);
        }
        let condition: Expr;
        let body: Stmt;
    }

}
