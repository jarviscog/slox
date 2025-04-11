
import Foundation

struct Lox {

    static var hadError: Bool = false

    static func main () {

        print("Running Lox...")

        let args = CommandLine.arguments
        print(args)
        if args.count > 2 {
            print("Usage slox [script]")
            return
        } else if args.count == 2 {
            self.runFile(path: args[1])
        } else {
            self.runPrompt()
        }
    }

    // TODO throws IOException
    static func runFile(path: String) {
        print("Running File...")

        let parse_result = try? String(contentsOf: URL(string: path)!, encoding: .utf8)

        if let contents = parse_result {
            print(contents)
            self.run(source: contents)
        }
    }

    static func runPrompt() {
        // TODO runPrompt
        while true {
            print("> ", terminator: "")
            if let line: String = readLine() {
                if line == "ee" {
                    return
                }
                self.run(source: line)
            } else {
                print("nil found")
            }
            hadError = false
        }
    }

    static func run(source: String) {

        print("Running source:")
        print(source)

        let scanner: Scanner = Scanner(source: source)
        let tokens: Array<Token> = scanner.scanTokens()
        for token in tokens { 
            print(token)
        }

    }

    static func error(line: Int32, message: String) {
        report(line: line, location: "", message: message)
    }

    static func report(line: Int32, location: String, message: String) {
        print("[line \(line)] Error \(location): \(message)")
        hadError = true
    }


}















