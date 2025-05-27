
import Foundation

@MainActor
struct Lox {

    static var hadError = false

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

        print(parse_result)

        if let contents = parse_result {
            print(contents)
            self.run(source: contents)
        }
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
        if let expr: Expr = parser.parse() {
            if (self.hadError) { return }
            print(AstPrinter().print(expr: expr))
        }
        print("\n")
    }

    static func error(line: Int, message: String) {
        Lox.report(line: line, location: "", message: message)
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







