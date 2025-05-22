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
            "Binary   - left: Expr , binary_operator: Token , right: Expr ", // NOTE operator is a keyword in swift
            "Grouping - expression: Expr ",
            "Literal  - value: Object ",
            "Unary    - unary_operator: Token , right: Expr "
        ]);
    }

    @available(macOS 10.15.4, *)
    static private func defineAst(outputDir: String, baseName: String, types: Array<String>) {
        print("outputDir " + outputDir)
        print("baseName " + baseName)
        let path: String = outputDir + "/" + baseName + ".swift"
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
            var contents: String = ""

            fileHandle.seekToEndOfFile()
            contents = ("class " + baseName + " {\n")
            try fileHandle.write(contentsOf: contents.data(using: .utf8)!)
            fileHandle.seekToEndOfFile()

            for token_type: String in types { 
                let className: String = token_type.components(separatedBy: "-")[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let fields: String = token_type.components(separatedBy: "-")[1].trimmingCharacters(in: .whitespacesAndNewlines)
                defineType(fileHandle, baseName, className, fields)

            }

            contents = ("}")
            try fileHandle.write(contentsOf: contents.data(using: .utf8)!)
            fileHandle.seekToEndOfFile()

        } 
        catch { 
            print("Error writing: \(error.localizedDescription)") 
        }
    }

    static private func defineType(_ fileHandle: FileHandle, _ baseName: String, _ className: String, _ fieldList: String) {
        do {
            var contents: String = "  static class " + className + ": " + baseName + " {\n";
            try fileHandle.write(contentsOf: contents.data(using: .utf8)!);
            fileHandle.seekToEndOfFile();

            contents = "    func " + className + "(" + fieldList + ") {\n";
            try fileHandle.write(contentsOf: contents.data(using: .utf8)!);
            fileHandle.seekToEndOfFile();

            let fields = fieldList.components(separatedBy: ",");
            for field: String in fields {
                let name: String = field.components(separatedBy: ":")[0].trimmingCharacters(in: .whitespacesAndNewlines)
                contents = "        self." + name + " = " + name + "\n";
                try fileHandle.write(contentsOf: contents.data(using: .utf8)!)
                fileHandle.seekToEndOfFile()
            }


            contents = "    }\n";
            try fileHandle.write(contentsOf: contents.data(using: .utf8)!);
            fileHandle.seekToEndOfFile();

            for field: String in fields {
                contents = "    final var " + field + ";\n";
                try fileHandle.write(contentsOf: contents.data(using: .utf8)!)
                fileHandle.seekToEndOfFile()
            }

            contents = "}\n";
            try fileHandle.write(contentsOf: contents.data(using: .utf8)!)
            fileHandle.seekToEndOfFile()

        } catch {
            print("Error writing: \(error.localizedDescription)") 
        }

    }

}
