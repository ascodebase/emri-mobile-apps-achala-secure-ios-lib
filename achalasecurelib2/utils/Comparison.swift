//import UIKit
//import Vision
//import AVFoundation
//import Foundation
//import CoreML
//import MLKit
//
//
//class Comparison {
//    
//    private var context: UIViewController?
//    private var model: FaceNetModel
//    private var faceList: [(String, [Float]?)] = []
//    private var nameScoreHashmap: [String: [Float]] = [:]
//    private var subject: [Float]
//    private var isProcessing = false
//    private let metricToBeUsed = "cosine"
//    private let SERIALIZED_DATA_FILENAME = "image_data"
//    private var textToSpeech: AVSpeechSynthesizer
//    private var achalaSecureCallback: AchalaSecureCallback
//    private var capturedImage :UIImage
//    
//    init(context: UIViewController, faceList: [(String, [Float])], achalaSecureCallback: AchalaSecureCallback, model: FaceNetModel,capturedImage:UIImage) throws {
//        self.context = context
//        self.achalaSecureCallback = achalaSecureCallback
//        self.model = model
//        self.faceList = faceList
//        self.subject = [Float](repeating: 0.0, count: self.model.embeddingDim)
//        self.textToSpeech = AVSpeechSynthesizer()
//        self.capturedImage = capturedImage
//        
//    }
//    
//    func runModel(faces: VNFaceObservation, cameraFrameBitmap: UIImage, faceFromProcessor: Face) {
//        print("Entered runModel with faces: \(faces)")
//        
//
//        var predictions: [Prediction] = []
//        
////        if faces.isEmpty {
////            print("No faces detected")
////            achalaSecureCallback.onCompareFailed(failed: "No faces detected")
////        }
//        
//        do {
//            // Assuming 'face' is the only face to compare
//            let boundingBox = faces.boundingBox
//            let croppedBitmap = cropImage( image: cameraFrameBitmap, toRect: faceFromProcessor.frame)
//            subject = try model.getFaceEmbedding(image: croppedBitmap!)!
//            
//            // Replace mask detection check if applicable
//            print("Starting comparison with face list: \(subject)")
//            
//            // Assuming faceList contains a single pair of name and embedding to compare
//            for (name, embedding) in faceList {
//                let distance: Float
//                if metricToBeUsed == "cosine" {
//                    distance = cosineSimilarity(x1: subject, x2: embedding!)
//                } else {
//                    distance = L2Norm(x1: subject, x2: embedding!)
//                }
//                
//                // Store distances in the hashmap for the name
//                if nameScoreHashmap[name] == nil {
//                    nameScoreHashmap[name] = [distance]
//                } else {
//                    nameScoreHashmap[name]?.append(distance)
//                }
//            }
//            
//            let avgScores = nameScoreHashmap.values.map { average(list: $0) }
//            let names = Array(nameScoreHashmap.keys)
//            nameScoreHashmap.removeAll()
//            
//            var bestScoreUserName = "Unknown"
//            
//            if metricToBeUsed == "cosine" {
//                // Find the maximum score from avgScores and check if it's greater than the threshold
//                let maxScore = avgScores.max() ?? 0.0
//                if maxScore > Double(self.model.getModel().getCosineThreshold()) {
//                    if let maxIndex = avgScores.firstIndex(of: maxScore) {
//                        bestScoreUserName = names[maxIndex]
//                    } else {
//                        bestScoreUserName = "Unknown"
//                    }
//                    }
//                } else {
//                    bestScoreUserName = "Unknown"
//                }
//                
//                // Log the method being used
//                print("cosine method")
//                
//                // Additional check for first score
//                if avgScores.first ?? 0.0 < 0.7 {
//                    bestScoreUserName = "Unknown"
//                }
//        
//            // Create a prediction result for the face comparison
//            predictions.append(Prediction(bbox: faces.boundingBox, label: bestScoreUserName))
//            
//            // Callback based on the comparison result
//            if bestScoreUserName == "Unknown" {
//                achalaSecureCallback.onCompareFailed(failed: "Unknown",score: "\(avgScores)")
//            } else {
//                achalaSecureCallback.onCompareSuccess(result: bestScoreUserName, score: "\(avgScores)",capturedImage:capturedImage)
//            }
//        } catch {
//            print("Error during model execution: \(error)")
//            achalaSecureCallback.onCompareFailed(failed: "Unknown",score: "0.0")
//        }
//    }
//    
//    private func cropImage(image: UIImage, toRect rect: CGRect) -> UIImage? {
//        // Ensure the cropping rectangle is within bounds of the original image
//        let scale = image.scale
//        let scaledRect = CGRect(
//            x: rect.origin.x * scale,
//            y: rect.origin.y * scale,
//            width: rect.size.width * scale,
//            height: rect.size.height * scale
//        )
//        
//        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else {
//            print("[ERROR] Unable to crop the image.")
//            return nil
//        }
//        
//        return UIImage(cgImage: cgImage, scale: scale, orientation: image.imageOrientation)
//    }
//    
//    private func L2Norm(x1: [Float], x2: [Float]) -> Float {
//        var sum: Float = 0.0
//        for i in 0..<x1.count {
//            sum += pow(x1[i] - x2[i], 2)
//        }
//        return sqrt(sum)
//    }
//    
//    private func cosineSimilarity(x1: [Float], x2: [Float]) -> Float {
//        var dot: Float = 0.0
//        var mag1: Float = 0.0
//        var mag2: Float = 0.0
//        for i in 0..<x1.count {
//            dot += x1[i] * x2[i]
//            mag1 += x1[i] * x1[i]
//            mag2 += x2[i] * x2[i]
//        }
//        return dot / (sqrt(mag1) * sqrt(mag2))
//    }
//    
//    private func average(list: [Float]) -> Double {
//        return list.map { Double($0) }.reduce(0, +) / Double(list.count)
//    }
//    
//    func onDestroy() {
//        // Clean up text-to-speech resources
//        textToSpeech.stopSpeaking(at: .immediate)
//    }
//}


import UIKit
import Vision
import AVFoundation
import CoreML
import MLKitFaceDetection
import MLKitVision

class Comparison {
    private var context: UIViewController?
    private var model: FaceNetModel
    private var faceList: [(String, [Float]?)] = []
    private var nameScoreHashmap: [String: [Float]] = [:]
    private var subject: [Float]
    private var isProcessing = false
    private let metricToBeUsed = "cosine"
    private let SERIALIZED_DATA_FILENAME = "image_data"
    private var textToSpeech: AVSpeechSynthesizer
    private var achalaSecureCallback: AchalaSecureCallback
    private var capturedImage: UIImage
    
    init(context: UIViewController, faceList: [(String, [Float])], achalaSecureCallback: AchalaSecureCallback, model: FaceNetModel, capturedImage: UIImage) throws {
        self.context = context
        self.achalaSecureCallback = achalaSecureCallback
        self.model = model
        self.faceList = faceList
        self.subject = [Float](repeating: 0.0, count: self.model.embeddingDim)
        self.textToSpeech = AVSpeechSynthesizer()
        self.capturedImage = capturedImage
    }
    
    func runModel(faces: VNFaceObservation, cameraFrameBitmap: UIImage, faceFromProcessor: Face) {
        print("Entered runModel with faces: \(faces)")
        var predictions: [Prediction] = []
        
        do {
            

            guard let croppedBitmap = resizeImage(image: cameraFrameBitmap, targetSize: CGSize(width: 160, height: 160)) else {
                print("[ERROR] Failed to crop the image.")
                achalaSecureCallback.onCompareFailed(failed: "No faces detected",score: "0.0")
                return
            }
            
            // Generate embedding for the cropped face
            subject = try model.getFaceEmbedding(image: croppedBitmap)!
            print("Entered runModel with faces: \(subject)")
            
            let compareFloat = faceList[0]
            
           let (cosineSim,l2Dist) =  compareFaces(embedding1: subject, embedding2: compareFloat.1!)

            print("Cosine Similarity: \(cosineSim)")
            print("L2 Distance: \(l2Dist)")

            
            
            
            // Compare the embedding with the stored embeddings
            for (name, embedding) in faceList {
                guard let embedding = embedding else { continue }
                
                let distance: Float
                if metricToBeUsed == "cosine" {
                    distance = cosineSimilarity(x1: subject, x2: embedding)
                } else {
                    distance = L2Norm(x1: subject, x2: embedding)
                }
                
                // Store distances in the hashmap for the name
                if nameScoreHashmap[name] == nil {
                    nameScoreHashmap[name] = [distance]
                } else {
                    nameScoreHashmap[name]?.append(distance)
                }
            }
            
            // Calculate average scores for each name
            let avgScores = nameScoreHashmap.values.map { average(list: $0) }
            let names = Array(nameScoreHashmap.keys)
            nameScoreHashmap.removeAll()
            
            // Determine the best match
            var bestScoreUserName = "Unknown"
            if metricToBeUsed == "cosine" {
                let maxScore = avgScores.max() ?? 0.0
                if maxScore > Double(self.model.getModel().getCosineThreshold()) {
                    if let maxIndex = avgScores.firstIndex(of: maxScore) {
                        bestScoreUserName = names[maxIndex]
                    }
                }
            } else {
                let minScore = avgScores.min() ?? 0.0
                if minScore < Double(self.model.getModel().getL2Threshold()) {
                    if let minIndex = avgScores.firstIndex(of: minScore) {
                        bestScoreUserName = names[minIndex]
                    }
                }
            }
            
            // Additional check for similarity score
            if avgScores.first ?? 0.0 < 0.7 {
                bestScoreUserName = "Unknown"
            }
            
            // Create a prediction result for the face comparison
            predictions.append(Prediction(bbox: faces.boundingBox, label: bestScoreUserName))
            
            // Callback based on the comparison result
            if bestScoreUserName == "Unknown" {
                achalaSecureCallback.onCompareFailed(failed: "Unknown",score: "\(avgScores)")
            } else {
                achalaSecureCallback.onCompareSuccess(result: bestScoreUserName, score: "\(avgScores)", capturedImage: capturedImage)
            }
        } catch {
            print("Error during model execution: \(error)")
            achalaSecureCallback.onCompareFailed(failed: "Unknown",score: "0.0")
        }
    }
    
    
    
    
    private func cropImage(image: UIImage, toRect rect: CGRect) -> UIImage? {
        // Ensure the cropping rectangle is within bounds of the original image
        let scale = image.scale
        let scaledRect = CGRect(
            x: rect.origin.x * scale,
            y: rect.origin.y * scale,
            width: rect.size.width * scale,
            height: rect.size.height * scale
        )
        
        guard let cgImage = image.cgImage?.cropping(to: scaledRect) else {
            print("[ERROR] Unable to crop the image.")
            return nil
        }
        
        return UIImage(cgImage: cgImage, scale: scale, orientation: image.imageOrientation)
    }
    


    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
        let size = image.size
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Determine new size keeping aspect ratio
        let newSize: CGSize
        if widthRatio > heightRatio {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
        }
        
        // Create a new image context
        UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }

    
    private func L2Norm(x1: [Float], x2: [Float]) -> Float {
        var sum: Float = 0.0
        for i in 0..<x1.count {
            sum += pow(x1[i] - x2[i], 2)
        }
        return sqrt(sum)
    }
    
    private func cosineSimilarity(x1: [Float], x2: [Float]) -> Float {
        var dot: Float = 0.0
        var mag1: Float = 0.0
        var mag2: Float = 0.0
        
        for i in 0..<x1.count {
            dot += x1[i] * x2[i]
            mag1 += x1[i] * x1[i]
            mag2 += x2[i] * x2[i]
        }
        
        return dot / (sqrt(mag1) * sqrt(mag2))
    }
    
    private func average(list: [Float]) -> Double {
        return list.map { Double($0) }.reduce(0, +) / Double(list.count)
    }
    
    func onDestroy() {
        // Clean up text-to-speech resources
        textToSpeech.stopSpeaking(at: .immediate)
    }
    private func preprocessImage(_ image: UIImage) -> UIImage? {
        let targetSize = CGSize(width: 160, height: 160) // Match the model's input size
        UIGraphicsBeginImageContextWithOptions(targetSize, true, 1.0)
        image.draw(in: CGRect(origin: .zero, size: targetSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}


   func cosineSimilarity(x1: [Float], x2: [Float]) -> Float {
       var dot: Float = 0.0
       var mag1: Float = 0.0
       var mag2: Float = 0.0
       
       for i in 0..<x1.count {
           dot += x1[i] * x2[i]
           mag1 += x1[i] * x1[i]
           mag2 += x2[i] * x2[i]
       }
       
       let magnitude = sqrt(mag1) * sqrt(mag2)
       return magnitude == 0 ? 0 : dot / magnitude
   }
   

   func l2Norm(x1: [Float], x2: [Float]) -> Float {
       var sum: Float = 0.0
       for i in 0..<x1.count {
           let diff = x1[i] - x2[i]
           sum += diff * diff
       }
       return sqrt(sum)
   }

   func compareFaces(embedding1: [Float], embedding2: [Float]) -> (cosineSimilarity: Float, l2Distance: Float) {
       let cosineSim = cosineSimilarity(x1: embedding1, x2: embedding2)
       let l2Dist = l2Norm(x1: embedding1, x2: embedding2)
       return (cosineSim, l2Dist)
   }
