

struct RuntimeError: Error {
    public let token: Token;
    public let message: String;


    init(token: Token, message: String) {
        self.token = token;
        self.message = message;
    }
}