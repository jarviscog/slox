

print("Hello world")

Lox.main()
struct Lox {
    static func main () {

        print("Running Lox...")

        let arguments = CommandLine.arguments
        print(arguments)

        for arg in arguments {
            print("\nType, arg")
            print(type(of: arg))
            print(arg)
        }

        
    }
}

