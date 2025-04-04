import UIKit
import TensorFlowLite

class FaceNetModel {

    private let imgSize: Int
    public let embeddingDim: Int
    private var interpreter: Interpreter?
    private var actModel: ModelInfo?

    init(modelPath: String, useGpu: Bool, actModel: ModelInfo) throws {
        self.imgSize = 160  // Example size, adjust according to your model
        self.embeddingDim = 128  // Example embedding dimension, adjust accordingly
        self.actModel = actModel
        var interpreterOptions = Interpreter.Options()

        // Use GPU Delegate if requested
        if useGpu {
//            if let delegate = try? GpuDelegate() {
//                interpreterOptions.addDelegate(delegate)
//            }
        } else {
            interpreterOptions.threadCount = 4
            interpreterOptions.isXNNPackEnabled = true
        }

        
        
////        // Load the TensorFlow Lite model
//        guard let modelURL = Bundle.main.url(forResource: modelPath, withExtension: "tflite") else {
//            throw NSError(domain: "FaceNetModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file not found"])
//        }
        
        // Load the TensorFlow Lite model
        guard let frameworkBundle = Bundle(identifier: "com.emri.achalasecurelib2"),
              let modelURL = frameworkBundle.url(forResource: modelPath, withExtension: "tflite") else {
            throw NSError(domain: "FaceNetModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file not found"])
        }
        
//        // Load the TensorFlow Lite model from the framework's bundle
//        guard let frameworkBundle = Bundle(for: FaceNetModel.self).path(forResource: "Achalasecure", ofType: "bundle"),
//              let bundle = Bundle(path: frameworkBundle),
//              let modelURL = bundle.url(forResource: modelPath, withExtension: "tflite") else {
//            throw NSError(domain: "FaceNetModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file not found in framework bundle"])
//        }
        
        
        
        self.interpreter = try Interpreter(modelPath: modelURL.path, options: interpreterOptions)
        try self.interpreter?.allocateTensors() // Allocate tensors after initialization
    }

    func getFaceEmbedding(image: UIImage) -> [Float]? {
        guard let inputData = convertBitmapToBuffer(image: image) else {
            print("Failed to convert image to buffer")
            return nil
        }

        do {
            // Step 1: Copy input data to the model
            try interpreter?.copy(inputData, toInputAt: 0)
            
            // Step 2: Run inference
            try interpreter?.invoke()
            
            // Step 3: Get the output tensor
            guard let outputTensor = try interpreter?.output(at: 0) else {
                print("Failed to get output tensor")
                return nil
            }
            
            // Step 4: Extract output data as [Float]
            let outputData = outputTensor.data
            return outputData.toFloatArray()
        } catch {
            print("Failed to run model: \(error)")
            return nil
        }
    }

    private func convertBitmapToBuffer(image: UIImage) -> Data? {
        let resizedImage = resizeImage(image: image, targetSize: CGSize(width: imgSize, height: imgSize))
        let pixelData = resizedImage.normalizedPixelData()
        return pixelData
    }

    /// Resize image to the required size
    private func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(targetSize, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return resizedImage
    }
    
    
    // Method to get the loaded TFLite model interpreter
    public func  getModel() -> ModelInfo {
        return actModel!
      }

}
extension Data {
    func toFloatArray() -> [Float] {
        return self.withUnsafeBytes {
            guard let pointer = $0.baseAddress else {
                return []
            }
            return [Float](UnsafeBufferPointer(
                start: pointer.bindMemory(to: Float.self, capacity: self.count),
                count: self.count / MemoryLayout<Float>.stride
            ))
        }
    }
}
extension UIImage {
    func normalizedPixelData() -> Data? {
        guard let cgImage = self.cgImage else { return nil }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerRow = width * 4
        var rawData = [UInt8](repeating: 0, count: width * height * 4)

        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            return nil
        }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Normalize to [0, 1]
        var floatData = [Float]()
        for i in 0..<(width * height) {
            let pixelIndex = i * 4
            floatData.append(Float(rawData[pixelIndex]) / 255.0)     // R
            floatData.append(Float(rawData[pixelIndex + 1]) / 255.0) // G
            floatData.append(Float(rawData[pixelIndex + 2]) / 255.0) // B
        }

        return Data(bytes: floatData, count: floatData.count * MemoryLayout<Float>.size)
    }
}
    
