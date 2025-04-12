
import Foundation

@MainActor
struct Lox {

    private static var hadError: Bool = false

    static func main () {

        print("Running Lox...")

        let args = CommandLine.arguments
        print(args)
        if args.count > 2 {
            print("Usage slox [script]")
            return
        } else if args.count == 2 {
            self.runFile(args[1])
        } else {
            self.runPrompt()
        }
    }

    // TODO throws IOException
    static func runFile(_ path: String) {
        print("Running File...")

        let fileURL = URL(fileURLWithPath: path)
        let parse_result = try? String(contentsOf: fileURL, encoding: .utf8)

        print(parse_result)

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
                if line == "exit" {
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

        //print("Running source:")
        //print(source)

        let scanner: Scanner = Scanner(source: source)
        let tokens: Array<Token> = scanner.scanTokens()
        for token in tokens { 
            print("TOKEN: \(token.toString())")
        }

    }

    static func error(line: Int, message: String) {
        report(line: line, location: "", message: message)
    }

    static func report(line: Int, location: String, message: String) {
        print("[line \(line)] Error \(location): \(message)")
        hadError = true
    }


}















