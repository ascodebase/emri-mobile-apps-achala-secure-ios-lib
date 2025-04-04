import UIKit
import TensorFlowLite

class FaceAntiSpoofing {
    private static let MODEL_FILE = "FaceAntiSpoofing"
    private static let INPUT_IMAGE_SIZE: Int = 256
    public static let THRESHOLD: Float = 0.2 // Static property
    public static let LAPLACIAN_THRESHOLD: Int = 150 // Static property
    private static let ROUTE_INDEX: Int = 6
    private static let LAPLACE_THRESHOLD: Int = 50

    private var interpreter: Interpreter

//    init() throws {
//        guard let modelPath = Bundle.main.path(forResource: FaceAntiSpoofing.MODEL_FILE, ofType: "tflite") else {
//            throw NSError(domain: "FaceAntiSpoofing", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file not found"])
//        }
//        var options = Interpreter.Options()
//        options.threadCount = 4
//        interpreter = try Interpreter(modelPath: modelPath, options: options)
//        try interpreter.allocateTensors()
//    }
    
    
    
    init() throws {
        // Dynamically get the framework's bundle using its identifier
        guard let frameworkBundle = Bundle(identifier: "com.emri.achalasecurelib2"),
              let modelPath = frameworkBundle.path(forResource: FaceAntiSpoofing.MODEL_FILE, ofType: "tflite") else {
            throw NSError(domain: "FaceAntiSpoofing", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file not found"])
        }

        // Configure TensorFlow Lite interpreter options
        var options = Interpreter.Options()
        options.threadCount = 4

        // Initialize the interpreter with the model path
        interpreter = try Interpreter(modelPath: modelPath, options: options)

        // Allocate tensors for the interpreter
        try interpreter.allocateTensors()
    }
    
    
//    init() throws {
//        // Get the framework's bundle
//        guard let frameworkBundle = Bundle(for: FaceAntiSpoofing.self).path(forResource: "Achalasecure", ofType: "bundle"),
//              let bundle = Bundle(path: frameworkBundle),
//              let modelPath = bundle.path(forResource: FaceAntiSpoofing.MODEL_FILE, ofType: "tflite") else {
//            throw NSError(domain: "FaceAntiSpoofing", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model file not found in framework bundle"])
//        }
//        
//        var options = Interpreter.Options()
//        options.threadCount = 4
//        interpreter = try Interpreter(modelPath: modelPath, options: options)
//        try interpreter.allocateTensors()
//    }

    
//    func antiSpoofing(bitmap: UIImage) -> Float {
//        guard let resizedBitmap = bitmap.resize(to: CGSize(width: FaceAntiSpoofing.INPUT_IMAGE_SIZE, height: FaceAntiSpoofing.INPUT_IMAGE_SIZE)) else {
//            return 0.0
//        }
//        
//        let normalizedImage = normalizeImage(bitmap: resizedBitmap)
//        let inputData = Data(buffer: UnsafeBufferPointer(start: normalizedImage, count: normalizedImage.count))
//        
//        do {
//            try interpreter.copy(inputData, toInputAt: 0)
//            try interpreter.invoke()
//            
//            // Get output tensors
//            let clssPredTensor = try interpreter.output(at: 0)
//            let leafNodeMaskTensor = try interpreter.output(at: 1)
//            
//            // Convert tensors to Swift arrays
//            let clssPredArray = try tensorToArray(tensor: clssPredTensor, type: Float.self)
//            let leafNodeMaskArray = try tensorToArray(tensor: leafNodeMaskTensor, type: Float.self)
//            
//            return leafScore1(clssPred: clssPredArray, leafNodeMask: leafNodeMaskArray)
//        } catch {
//            print("Error running model: \(error)")
//            return 0.0
//        }
//    }
    
    func antiSpoofing(bitmap: UIImage) -> Float {
        // Resize the input bitmap
        guard let resizedBitmap = bitmap.resize(to: CGSize(width: FaceAntiSpoofing.INPUT_IMAGE_SIZE, height: FaceAntiSpoofing.INPUT_IMAGE_SIZE)) else {
            return 0.0
        }
        
        // Normalize the resized bitmap
        let normalizedImage = normalizeImage(bitmap: resizedBitmap)
        
        // Convert the [Float] array to a byte array ([UInt8])
        var byteArray = [UInt8]()
        normalizedImage.withUnsafeBufferPointer { bufferPointer in
            let floatBytes = UnsafeRawBufferPointer(bufferPointer)
            byteArray.append(contentsOf: floatBytes)
        }
        
        // Create a Data object from the byte array
        let inputData = Data(byteArray)
        
        do {
            // Copy input data to the interpreter
            try interpreter.copy(inputData, toInputAt: 0)
            try interpreter.invoke()
            
            // Get output tensors
            let clssPredTensor = try interpreter.output(at: 0)
            let leafNodeMaskTensor = try interpreter.output(at: 1)
            
            // Convert tensors to Swift arrays
            let clssPredArray = try tensorToArray(tensor: clssPredTensor, type: Float.self)
            let leafNodeMaskArray = try tensorToArray(tensor: leafNodeMaskTensor, type: Float.self)
            
            // Compute and return the leaf score
            return leafScore1(clssPred: clssPredArray, leafNodeMask: leafNodeMaskArray)
        } catch {
            print("Error running model: \(error)")
            return 0.0
        }
    }
    
    private func leafScore1(clssPred: [Float], leafNodeMask: [Float]) -> Float {
        var score: Float = 0.0
        for i in 0..<8 {
            score += abs(clssPred[i]) * leafNodeMask[i]
        }
        return score
    }
    
    private func leafScore2(clssPred: [Float]) -> Float {
        return clssPred[FaceAntiSpoofing.ROUTE_INDEX]
    }
    
    private func normalizeImage(bitmap: UIImage) -> [Float] {
        guard let cgImage = bitmap.cgImage else { return [] }
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        var pixels = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(data: &pixels, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return []
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var floatValues = [Float]()
        let imageStd: Float = 255.0
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * bytesPerPixel
                let r = Float(pixels[pixelIndex]) / imageStd
                let g = Float(pixels[pixelIndex + 1]) / imageStd
                let b = Float(pixels[pixelIndex + 2]) / imageStd
                
                floatValues.append(r)
                floatValues.append(g)
                floatValues.append(b)
            }
        }
        
        return floatValues
    }
    
    func laplacian(bitmap: UIImage) -> Int {
        guard let resizedBitmap = bitmap.resize(to: CGSize(width: FaceAntiSpoofing.INPUT_IMAGE_SIZE, height: FaceAntiSpoofing.INPUT_IMAGE_SIZE)) else {
            return 0
        }
        
        let laplace = [[0, 1, 0], [1, -4, 1], [0, 1, 0]]
        let size = laplace.count
        guard let greyImage = convertGreyImg(bitmap: resizedBitmap) else {
            return 0
        }
        
        let height = greyImage.count
        let width = greyImage[0].count
        
        var score = 0
        for x in 0..<(height - size + 1) {
            for y in 0..<(width - size + 1) {
                var result = 0
                for i in 0..<size {
                    for j in 0..<size {
                        result += Int(greyImage[x + i][y + j]) * laplace[i][j]
                    }
                }
                if result > FaceAntiSpoofing.LAPLACE_THRESHOLD {
                    score += 1
                }
            }
        }
        return score
    }
    
    private func convertGreyImg(bitmap: UIImage) -> [[UInt8]]? {
        guard let cgImage = bitmap.cgImage else { return nil }
        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitsPerComponent = 8
        var pixels = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        
        guard let context = CGContext(data: &pixels, width: width, height: height, bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil
        }
        
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        
        var greyImage = [[UInt8]](repeating: [UInt8](repeating: 0, count: width), count: height)
        
        for y in 0..<height {
            for x in 0..<width {
                let pixelIndex = (y * width + x) * bytesPerPixel
                let r = pixels[pixelIndex]
                let g = pixels[pixelIndex + 1]
                let b = pixels[pixelIndex + 2]
                let grey = UInt8((Float(r) * 0.299 + Float(g) * 0.587 + Float(b) * 0.114))
                greyImage[y][x] = grey
            }
        }
        
        return greyImage
    }
    
    private func tensorToArray<T>(tensor: Tensor, type: T.Type) throws -> [T] where T: ExpressibleByIntegerLiteral {
        let count = tensor.shape.dimensions.reduce(1, *)
        let byteCount = count * MemoryLayout<T>.stride
        var array = [T](repeating: 0, count: count)
        try array.withUnsafeMutableBytes { buffer in
            guard let baseAddress = buffer.baseAddress else {
                throw NSError(domain: "FaceAntiSpoofing", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to get base address"])
            }
            let status = tensor.data.copyBytes(to: UnsafeMutableRawBufferPointer(start: baseAddress, count: byteCount))
            if status != byteCount {
                throw NSError(domain: "FaceAntiSpoofing", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to copy tensor data"])
            }
        }
        return array
    }
}

extension UIImage {
    func resize(to size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, self.scale)
        defer { UIGraphicsEndImageContext() }
        self.draw(in: CGRect(origin: .zero, size: size))
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
