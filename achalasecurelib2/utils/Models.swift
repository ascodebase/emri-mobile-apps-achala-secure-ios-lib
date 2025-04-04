import Foundation

class Models {

    static let FACENET = ModelInfo(
        name: "FaceNet",
        assetsFilename: "facenet.tflite",
        cosineThreshold: 0.4,
        l2Threshold: 10.0,
        outputDims: 128,
        inputDims: 160
    )

    static let FACENET_512 = ModelInfo(
        name: "FaceNet-512",
        assetsFilename: "facenet_512.tflite",
        cosineThreshold: 0.3,
        l2Threshold: 23.56,
        outputDims: 512,
        inputDims: 160
    )

    static let FACENET_QUANTIZED = ModelInfo(
        name: "FaceNet Quantized",
        assetsFilename: "facenet_int_quantized.tflite",
        cosineThreshold: 0.4,
        l2Threshold: 10.0,
        outputDims: 128,
        inputDims: 160
    )

    static let FACENET_512_QUANTIZED = ModelInfo(
        name: "FaceNet-512 Quantized",
        assetsFilename: "facenet_512_int_quantized.tflite",
        cosineThreshold: 0.3,
        l2Threshold: 23.56,
        outputDims: 512,
        inputDims: 160
    )
}
