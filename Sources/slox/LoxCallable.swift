import Foundation

protocol LoxCallable {
    func arity() -> Int
    func call(_ interpreter: Interpreter, _ arguments: [Any?]) -> Any?
    func toString() -> String
}

struct Clock: LoxCallable {
    func arity() -> Int { 0 }
    func call(_ interpreter: Interpreter, _ arguments: [Any?]) -> Any? {
        return Date().timeIntervalSince1970
    }
    func toString() -> String { return "<native fn>"}
}