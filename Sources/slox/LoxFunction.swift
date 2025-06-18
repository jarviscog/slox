
class LoxFunction: LoxCallable {
    private final let declaration: Stmt.Function
    private final closure: Environment;
    func arity() -> Int { declaration.params.count }
    init(declaration: Stmt.Function, closure: Environment) {
        self.declaration = declaration
        self.closure = closure
    }
    func call(_ interpreter: Interpreter, _ arguments: [Any?]) -> Any? {
        let environment: Environment = Environment(enclosing: closure)
        for i in 0..<declaration.params.count {
            environment.define(name: declaration.params[i].lexeme, value: arguments[i])
        }
        do {
            interpreter.executeBlock(statements: declaration.body, environment: environment)
        } catch let r as Return {
            return r.value
        }
        return nil;
    }

    func toString() -> String {
        return "<fn \(declaration.name.lexeme)>"
    }
    
}