import UIKit

public class AchalaSecureResultModel: Codable {
    public var score: String?
    public var bitmapResultData: Data?  // Store the image as Data
    public var status: String?
    public var message: String?

    // Computed property to return the UIImage once data is decoded
    public var bitmapResult: UIImage? {
        guard let data = bitmapResultData else { return nil }
        return UIImage(data: data)
    }

    // Initializer
    public init(score: String? = nil, bitmapResultData: Data? = nil, status: String? = nil, message: String? = nil) {
        self.score = score
        self.bitmapResultData = bitmapResultData
        self.status = status
        self.message = message
    }

    // Getters and Setters
    public func getMessage() -> String? {
        return message
    }

    public func setMessage(_ message: String) {
        self.message = message
    }

    public func getStatus() -> String? {
        return status
    }

    public func setStatus(_ status: String) {
        self.status = status
    }

    public func getBitmapResult() -> UIImage? {
        return bitmapResult
    }

    public func setBitmapResult(_ bitmapResult: UIImage) {
        self.bitmapResultData = bitmapResult.pngData() // Convert UIImage to Data
    }

    public func getScore() -> String? {
        return score
    }

    public func setScore(_ score: String) {
        self.score = score
    }
}
