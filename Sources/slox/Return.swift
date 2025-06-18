
struct Return: Error {
    let value: LiteralValue

    init(_ value: LiteralValue) {
        self.value = value
    }
}