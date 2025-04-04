import Foundation

class ModelInfo {

    private let name: String
    private let assetsFilename: String
    private let cosineThreshold: Float
    private let l2Threshold: Float
    private let outputDims: Int
    private let inputDims: Int

    // Initializer
    init(name: String, assetsFilename: String, cosineThreshold: Float, l2Threshold: Float, outputDims: Int, inputDims: Int) {
        self.name = name
        self.assetsFilename = assetsFilename
        self.cosineThreshold = cosineThreshold
        self.l2Threshold = l2Threshold
        self.outputDims = outputDims
        self.inputDims = inputDims
    }

    // Getter methods for each field
    func getName() -> String {
        return name
    }

    func getAssetsFilename() -> String {
        return assetsFilename
    }

    func getCosineThreshold() -> Float {
        return cosineThreshold
    }

    func getL2Threshold() -> Float {
        return l2Threshold
    }

    func getOutputDims() -> Int {
        return outputDims
    }

    func getInputDims() -> Int {
        return inputDims
    }
}
