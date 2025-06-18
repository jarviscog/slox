import Foundation

@main
@available(macOS 10.15.4, *)
struct GenerateAST {

    @available(macOS 10.15.4, *)
    static func main () {

        print("Generating AST...")

        let args = CommandLine.arguments
        print("Args: ", args)
        if args.count != 2 {
            print("Usage: generate_ast <output directory>")
            return
        } 

        let outputDir: String = args[1];
        defineAst(outputDir: outputDir, baseName: "Expr", types: [
            "Assignment  - name: Token, value: Expr",
            "Binary      - left: Expr , binary_operator: Token , right: Expr ", // NOTE operator is a keyword in swift
            "Call        - callee: Expr, paren: Token, arguments: [Expr]",
            "Grouping    - expression: Expr ",
            "Literal     - value: Any?",
            "Logical     - left: Expr, logical_operator: Token, right: Expr",
            "Unary       - unary_operator: Token , right: Expr ",
            "Variable    - name: Token",
        ]);

        defineAst(outputDir: outputDir, baseName: "Stmt", types: [
            "Block       - statements: [Stmt]",
            "Expression  - expression: Expr",
            "Function    - name: Token, params: [Token], body: [Stmt]",
            "If          - condition: Expr, thenBranch: Stmt, elseBranch: Stmt",
            "Print       - expression: Expr",
            "Return      - keyword: Token, value: Expr",
            "Var         - name: Token, initializer: Expr",
            "While       - condition: Expr, body: Stmt",
        ]);
    }

    @available(macOS 10.15.4, *)
    static private func defineAst(outputDir: String, baseName: String, types: Array<String>) {
        print("outputDir " + outputDir)
        print("baseName " + baseName)
        let path: String = "\(outputDir)/\(baseName).swift"
        print("outputDir " + path)
        print(FileManager.default.currentDirectoryPath)
        let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent(path)

        // Create file if it doesn't exist
        if !FileManager.default.fileExists(atPath: fileURL.path) {
            FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
        }
        
        // Clear file contents
        do {
            try "".write(toFile: path, atomically: true, encoding: .utf8)
            print("File cleared and recreated.")
        } catch {
            print("Failed to clear file: \(error)")
        }

        do { 
            let fileHandle: FileHandle = try FileHandle(forWritingTo: fileURL)
            defer { fileHandle.closeFile() }

            fileHandle.seekToEndOfFile()
            defineVisitor(fileHandle, baseName, types);
            appendToFile(fileHandle, "class \(baseName) {\n")
            appendToFile(fileHandle, "\n")
            appendToFile(fileHandle, "    func accept<V: \(baseName)Visitor, R>(visitor: V) -> R where R == V.R {\n")
            appendToFile(fileHandle, "        fatalError()\n")
            appendToFile(fileHandle, "    }\n")

            for token_type: String in types { 
                let className: String = token_type.components(separatedBy: "-")[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let fields: String = token_type.components(separatedBy: "-")[1].trimmingCharacters(in: .whitespacesAndNewlines)
                defineType(fileHandle, baseName, className, fields)
            }


            appendToFile(fileHandle, "}\n")
        } 
        catch { 
            print("Error writing: \(error.localizedDescription)") 
        }
    }

    static private func defineType(_ fileHandle: FileHandle, _ baseName: String, _ className: String, _ fieldList: String) {
        appendToFile(fileHandle, "    class \(className): \(baseName) {\n");
        appendToFile(fileHandle, "        init" + "(\(fieldList)) {\n");

        let fields = fieldList.components(separatedBy: ",");
        for field: String in fields {
            let name: String = field.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespacesAndNewlines)
            appendToFile(fileHandle, "            self.\(name) = \(name)\n")
        }
        appendToFile(fileHandle, "        }\n")

        // Visitor pattern
        appendToFile(fileHandle, "\n")
        appendToFile(fileHandle, "        override func accept<V: \(baseName)Visitor, R>(visitor: V) -> R where R == V.R {\n")
        appendToFile(fileHandle, "            return visitor.visit\(className)\(baseName)(self);\n")
        appendToFile(fileHandle, "        }\n")

        // Fields
        for field: String in fields {
            let field_trimmed: String = field.trimmingCharacters(in: .whitespacesAndNewlines)
            appendToFile(fileHandle, "        let \(field_trimmed);\n")
        }

        appendToFile(fileHandle, "    }\n\n")

    }

    static private func defineVisitor(_ fileHandle: FileHandle, _ baseName: String, _ types: Array<String>) {
        appendToFile(fileHandle, "protocol \(baseName)Visitor<R> {\n")
        appendToFile(fileHandle, "  associatedtype R\n")

        for type in types {
            let typeName: String = type.components(separatedBy: "-")[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let contents: String = "  func visit\(typeName)\(baseName)(_ \(baseName.lowercased()): \(baseName).\(typeName)) -> R;\n"
            appendToFile(fileHandle, contents);
        }
        appendToFile(fileHandle, "}\n\n")
    }

    static func appendToFile(_ fileHandle: FileHandle, _ in_string: String) {
        do {
            try fileHandle.write(contentsOf: in_string.data(using: .utf8)!);
            fileHandle.seekToEndOfFile();
        } catch {
            print("Error writing: \(error.localizedDescription)") 
        }
    }
}
