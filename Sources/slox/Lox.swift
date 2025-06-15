
import Foundation

@MainActor
struct Lox {

    private static var interpreter: Interpreter = Interpreter()
    static var hadError: Bool = false
    static var hadRuntimeError: Bool = false

    static func main () {

        print("Running Lox...")

        let args = CommandLine.arguments
        print(args)
        if args.count > 2 {
            print("Usage slox [script]")
            return
        } else if args.count == 2 {
            runFile(args[1])
        } else {
            runPrompt()
        }
    }

    // TODO throws IOException
    private static func runFile(_ path: String) {
        print("Running File...")

        let fileURL = URL(fileURLWithPath: path)
        let parse_result = try? String(contentsOf: fileURL, encoding: .utf8)

        if let contents = parse_result {
            print(contents)
            self.run(source: contents)
        }

        if hadError { exit(65) }
        if hadRuntimeError { exit(70) }
    }

    private static func runPrompt() {
        // TODO runPrompt
        while true {
            print("> ", terminator: "")
            if let line: String = readLine() {
                if line == "ee" {
                    return
                }
                if line == "exit" {
                    return
                }
                self.run(source: line)
            } else {
                print("nil found")
            }
            Lox.hadError = false
        }
    }

    private static func run(source: String) {

        let scanner: Scanner = Scanner(source: source)
        let tokens: Array<Token> = scanner.scanTokens()
        let parser: Parser = Parser(tokens: tokens)

        let statements: [Stmt] = try! parser.parse();
        if (self.hadError) { return }
        self.interpreter.interpret(statements: statements)
        //print("\n")
    }

    static func error(line: Int, message: String) {
        Lox.report(line: line, location: "", message: message)
    }

    static func runtimeError(_ runtime_error: RuntimeError) {

        print(runtime_error.message + "\n[Line " + String(runtime_error.token.line) + "]")
        self.hadRuntimeError = true
    }

    private static func report(line: Int, location: String, message: String) {
        print("[line \(line)] Error \(location): \(message)")
        Lox.hadError = true
    }

    static func error(token: Token, message: String) {
        if (token.type == TokenType.EOF) {
            Lox.report(line: token.line, location: " at end", message: message)
        } else {
            Lox.report(line: token.line, location: " at '" + token.lexeme + "'", message: message)
        }
    }

}







