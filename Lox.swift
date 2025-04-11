
import Foundation

print("Hello world")

Lox.main()
struct Lox {
    static func main () {

        print("Running Lox...")

        let args = CommandLine.arguments
        print(args)
        if args.count > 1 {
            print("Usage slox [script]")
            return
        } else if args.count == 1 {
            runFile(path: args[1])
        } else {
            runPrompt()
        }
    }

    static func runFile(path: String) {
        // TODO throws IOException
        print("Running File...")
        let fileURL = URL(fileURLWithPath: path)

        do {
            let fileData = try Data(contentsOf: fileURL)
        } catch {
            print('')
        }



            
        //let bytes: [Uint8] = 


    }

    static func runPrompt() {
        // TODO runPrompt
        while true {
            print("> ")
            let input: String? = readLine()
            if input == nil {
                break
            }
        }
    }

}

