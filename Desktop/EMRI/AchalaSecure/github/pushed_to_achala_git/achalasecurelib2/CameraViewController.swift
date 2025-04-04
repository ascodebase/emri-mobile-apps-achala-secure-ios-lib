//
//  CameraViewController.swift
//  achalasecurelib2
//
//  Created by EMRI on 12/02/25.
//
import SwiftUI
import UIKit
import AVFoundation
import MLKitFaceDetection
import MLKitVision
import Vision

public class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var onDismiss: (() -> Void)?
    var onFaceDetection: ((Int) -> Void)?
    var faceResult: ((AchalaSecureResultModel) -> Void)?
    var verifyUser: UIImage?
    var isVerifyUser: Bool?

    private var frameCount = 0
    var imageView: UIImageView!
    private var faceAntiSpoofing: FaceAntiSpoofing!
    private var userGid = "Verify_User";
    private var model: FaceNetModel?

    
    
    var isRegistration: Bool = false
       // var achalaSecureResultModel = AchalaSecureResultModel()
        var facesList = [(String, [Float])]()
        var imageFromThePath: UIImage!
        var progressDialog: UIActivityIndicatorView?

        var previewView: UIView!
    
    
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        // Initialize imageView
        imageView = UIImageView(frame: view.bounds)
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView) // Add imageView to the view hierarchy
        initAntiSpoofing()
    
        do {
            let modelInfo =   ModelInfo(name: "FaceNet",
                assetsFilename: "facenet.tflite",
                cosineThreshold: 0.4,
                l2Threshold: 10.0,
                outputDims: 128,
                inputDims: 160)
            
            
            // Verify file existence
                    if let filePath = Bundle.main.path(forResource: "facenet", ofType: "tflite") {
                        print("File found at path: \(filePath)")
                    } else {
                        print("File not found in bundle")
                    }
            
            
            model = try FaceNetModel(modelPath: "facenet", useGpu: false, actModel: modelInfo)
            print("FaceNetModel: Model initialized successfully")
        } catch {
            print("FaceNetModel: Model initialization failed \(error)")
        }

        setupCamera()
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.addTarget(self, action: #selector(closeCamera), for: .touchUpInside)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
       
        let bottomRibbon = UIView()
        bottomRibbon.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        bottomRibbon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomRibbon)

        // Left label (AchalaSecure)
        let leftLabel = UILabel()
        leftLabel.text = "AchalaSecure"
        leftLabel.font = UIFont.systemFont(ofSize: 14)
        leftLabel.textColor = .white
        leftLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomRibbon.addSubview(leftLabel)

        // Right label (1.0.0)
        let rightLabel = UILabel()
        rightLabel.text = "1.0.0"
        rightLabel.font = UIFont.systemFont(ofSize: 14)
        rightLabel.textColor = .white
        rightLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomRibbon.addSubview(rightLabel)

        // Constraints for bottom ribbon
        NSLayoutConstraint.activate([
            bottomRibbon.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomRibbon.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomRibbon.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomRibbon.heightAnchor.constraint(equalToConstant: 40),
            
            leftLabel.leadingAnchor.constraint(equalTo: bottomRibbon.leadingAnchor, constant: 10),
            leftLabel.centerYAnchor.constraint(equalTo: bottomRibbon.centerYAnchor),
            
            rightLabel.trailingAnchor.constraint(equalTo: bottomRibbon.trailingAnchor, constant: -10),
            rightLabel.centerYAnchor.constraint(equalTo: bottomRibbon.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc func closeCamera() {
        captureSession.stopRunning()
        onDismiss?()
    }
    
//    private func setupCamera() {
//        captureSession = AVCaptureSession()
//        captureSession.sessionPreset = .high
//        
//        
//        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
//            print("[ERROR] Unable to access the front camera.")
//            return
//        }
//        
//        do {
//            let input = try AVCaptureDeviceInput(device: camera)
//            if captureSession.canAddInput(input) {
//                captureSession.addInput(input)
//            }
//            
//            let videoOutput = AVCaptureVideoDataOutput()
//            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
//            if captureSession.canAddOutput(videoOutput) {
//                captureSession.addOutput(videoOutput)
//            }
//            if let connection = videoOutput.connection(with: .video) {
//                connection.videoOrientation = .portrait
//                connection.isVideoMirrored = true
//            }
//            
//            
//            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
//            videoPreviewLayer.frame = view.bounds
//            videoPreviewLayer.videoGravity = .resizeAspectFill
//            view.layer.addSublayer(videoPreviewLayer)
//            
//            captureSession.startRunning()
//        } catch {
//            print("[ERROR] Error accessing camera: \(error.localizedDescription)")
//        }
//    }
    
    private func setupCamera() {
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .high

        // Access the front camera
        guard let camera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("[ERROR] Unable to access the front camera.")
            return
        }

        do {
            // Add input to the capture session
            let input = try AVCaptureDeviceInput(device: camera)
            if captureSession.canAddInput(input) {
                captureSession.addInput(input)
            }

            // Configure video output
            let videoOutput = AVCaptureVideoDataOutput()
            videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
            }

            // Configure video connection
            if let connection = videoOutput.connection(with: .video) {
                connection.videoOrientation = .portrait
                connection.isVideoMirrored = true
            }

            // Set up the preview layer
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer.frame = view.bounds
            videoPreviewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(videoPreviewLayer)

            // Start the capture session on a background thread
            DispatchQueue.global(qos: .userInitiated).async {
                self.captureSession.startRunning()
            }
        } catch {
            print("[ERROR] Error accessing camera: \(error.localizedDescription)")
        }
    }
    
    public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        frameCount += 1
        if frameCount % 30 != 0 { return } // Process every 10th frame
        
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
        let context = CIContext()
        
        guard let cgImage = context.createCGImage(ciImage, from: ciImage.extent) else {
            print("[ERROR] Failed to create CGImage from CIImage.")
            return
        }
        
        let uiImage = UIImage(cgImage: cgImage, scale: 1.0, orientation: .up) // Always ensures CGImage is valid
        let visionImage = VisionImage(image: uiImage)
        visionImage.orientation = .up
        
        let options = FaceDetectorOptions()
        options.performanceMode = .accurate
        options.landmarkMode = .all
        options.contourMode = .all
        options.classificationMode = .all
        
        let faceDetector = FaceDetector.faceDetector(options: options)
        faceDetector.process(visionImage) { [self] faces, error in
            if let error = error {
                print("[ERROR] Face detection failed: \(error.localizedDescription)")
                return
            }
            
            if let faces = faces {
                
                print("[LOG] \(faces.count) face(s) detected.")
                self.onFaceDetection?(faces.count)
                //self.drawFaces(faces, onImage: uiImage)
                
                if(faces.count == 1 && detectEyesOpen(face: faces[0])){
                    let frame = faces[0].frame
                    if let croppedImage = self.cropImage(uiImage, toRect: frame){
                        if self.runModel(face: convertToVNFaceObservation(face: faces[0], imageSize: croppedImage.size)!, cameraFrameBitmap: croppedImage) != nil{
                            
                        
                        if(self.checkQualityWithModel(bitmap: croppedImage)){
                            captureSession?.stopRunning()
                            
                            // Remove the video preview layer
                            videoPreviewLayer?.removeFromSuperlayer()
                            videoPreviewLayer = nil
                            
                            // Optionally, you can set capture session to nil to release it
                            captureSession = nil
                            self.compareFaces(facese: convertToVNFaceObservation(face: faces[0], imageSize: croppedImage.size)!, originalImage: croppedImage, faceFromProcessor: faces[0],capturedImage: uiImage)
                        }
                        }
                    }
                }
                
            } else {
                print("[LOG] No faces detected.")
                self.onFaceDetection?(0)
            }
        }
    }
    func drawFaces1(_ faces: [Face], onImage image: UIImage) {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(at: CGPoint.zero)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            print("[ERROR] Unable to get drawing context.")
            return
        }
        
        context.setLineWidth(3.0)
        context.setStrokeColor(UIColor.red.cgColor)
        context.setFillColor(UIColor.clear.cgColor)
        
        for face in faces {
            let frame = face.frame
            context.addRect(frame)
            context.strokePath()
        }
        
        let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        DispatchQueue.main.async {
            // Update the UIImageView with the drawn image
            self.imageView.image = drawnImage
        }
    }
    
    
    func drawFaces(_ faces: [Face], onImage image: UIImage) {
        UIGraphicsBeginImageContextWithOptions(image.size, false, image.scale)
        image.draw(at: CGPoint.zero)
        
        guard let context = UIGraphicsGetCurrentContext() else {
            print("[ERROR] Unable to get drawing context.")
            return
        }
        
        context.setLineWidth(3.0)
        context.setStrokeColor(UIColor.red.cgColor)
        context.setFillColor(UIColor.clear.cgColor)
        
        for face in faces {
            let frame = face.frame
            context.addRect(frame)
            context.strokePath()
            
            // Crop the face from the image based on the frame
            let croppedImage = cropImage(image, toRect: frame)
            
            // Show the cropped face in a dialog
            showCroppedFaceDialog(croppedImage)
        }
        
        let drawnImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        DispatchQueue.main.async {
            // Update the UIImageView with the drawn image
            self.imageView.image = drawnImage
        }
    }
    
    private func cropImage(_ image: UIImage, toRect rect: CGRect) -> UIImage? {
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
    
    private func showCroppedFaceDialog(_ croppedImage: UIImage?) {
        guard let croppedImage = croppedImage else { return }
        
        // Create an image view to display the cropped face
        let imageView = UIImageView(image: croppedImage)
        imageView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        imageView.contentMode = .scaleAspectFit
        
        // Create an alert controller
        let alertController = UIAlertController(title: "Cropped Face", message: nil, preferredStyle: .alert)
        
        // Add the image view to the alert
        alertController.view.addSubview(imageView)
        
        // Show the alert controller
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
        
        // Add a dismiss button to the alert
        let dismissAction = UIAlertAction(title: "Close", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(dismissAction)
    }
    
    func initAntiSpoofing() {
        // Initialize FaceAntiSpoofing model
        if let fas = try? FaceAntiSpoofing() {
            self.faceAntiSpoofing = fas
        } else {
            print("Failed to initialize FaceAntiSpoofing model")
        }
    }
    
    func checkQualityWithModel(bitmap: UIImage) -> Bool {
        // Ensure the FaceAntiSpoofing model is initialized
        guard let fas = faceAntiSpoofing else {
            print("FaceAntiSpoofing model not initialized")
            return false
        }

        // Step 1: Check the clarity of the image using Laplacian
        let laplaceScore = fas.laplacian(bitmap: bitmap)
        print(laplaceScore)

        var text = "Quality detection: \(laplaceScore)"
        if laplaceScore < FaceAntiSpoofing.LAPLACIAN_THRESHOLD { // Use the class name to access the static property
            text += "，False"
            //print("Quality detection failed")
            print(text)
            return false
        } else {
            // Step 2: Perform liveness detection
            _ = Date().timeIntervalSince1970 // Start timing
            let livenessScore = fas.antiSpoofing(bitmap: bitmap)
            _ = Date().timeIntervalSince1970   // End timing

            text = "Liveness detection: \(livenessScore)"
            print("checkQualityWithModel: \(FaceAntiSpoofing.THRESHOLD)") // Use the class name to access the static property

            if livenessScore < FaceAntiSpoofing.THRESHOLD { // Use the class name to access the static property
                // Detection passed
                return true
            } else {
                //text += "，False"
                print(text)
                return false
            }
        }
    }
    
    
    func compareFaces(facese: VNFaceObservation, originalImage: UIImage, faceFromProcessor : Face, capturedImage: UIImage) {
        do {
            let comparisonHandler = ComparisonHandler(viewController: self)
            
            // Clear facesList before adding new entries
            if !facesList.isEmpty {
                facesList.removeAll()
            }
            
            // Proceed if there's exactly one face in the input and if no progressDialog exists
            if progressDialog == nil {
                if let cameraPreview = self.runModel(face: facese, cameraFrameBitmap: originalImage) {
                    self.facesList.append((self.userGid, cameraPreview))
               
                    print("processImage: \(self.facesList)")
                 
                    let isMobileFaceNet = false
                    self.isRegistration = isVerifyUser ?? false
                    if !isMobileFaceNet {
                        if !self.isRegistration {
                            let comparations =  try Comparison(context: self, faceList:  facesList, achalaSecureCallback: comparisonHandler, model: model!,capturedImage: capturedImage)
                            comparations.runModel(faces: facese, cameraFrameBitmap: originalImage, faceFromProcessor: faceFromProcessor)
                        } else {
                            // Handle authentication
                            let comparations =  try Comparison(context: self, faceList:  facesList, achalaSecureCallback: comparisonHandler, model: model!,capturedImage: capturedImage)
                            //    comparations.runModel(faces: facese, cameraFrameBitmap: verifyUser!, faceFromProcessor: faceFromProcessor)
                            verifyEmployee(comparation: comparations,verifyImage: verifyUser!)
                        }
                    }
                   
                } else {
                    print("runModel returned nil")
                }

            }
        } catch {
            // Catch and handle any errors
            print("An error occurred during face comparison: \(error)")
        }
    }

    

    
    func runModel(face: VNFaceObservation, cameraFrameBitmap: UIImage) -> [Float]? {
        print("runModel: entered \(face)")

        do {
            let boundingBox = face.boundingBox

            // Validate bounding box: ensure it doesn't go outside the image boundaries
            let maxX = min(boundingBox.origin.x + boundingBox.size.width, cameraFrameBitmap.size.width)
            let maxY = min(boundingBox.origin.y + boundingBox.size.height, cameraFrameBitmap.size.height)

            let width = maxX - boundingBox.origin.x
            let height = maxY - boundingBox.origin.y

            // If bounding box is invalid (too small or outside image boundaries)
            if width <= 0 || height <= 0 {
                print("Invalid bounding box dimensions: \(boundingBox)")
                return nil
            } else {
                print("Valid bounding box: \(boundingBox)")

                // Ensure bounding box stays within valid bounds
                let adjustedBoundingBox = CGRect(
                    x: boundingBox.origin.x,
                    y: boundingBox.origin.y,
                    width: width,
                    height: height
                )

//                // Crop the image based on the adjusted bounding box
                guard let croppedBitmap = resizeImage(image: cameraFrameBitmap, targetSize: CGSize(width: 160, height: 160)) else {
                    print("Failed to crop image")
                    return nil
                }
                print("Cropping successful")

            
                // Get face embeddings
                guard let currentFaceEmbeddings = model!.getFaceEmbedding(image: croppedBitmap) else {
                    print("Failed to get face embeddings")
                    return nil
                }
                return currentFaceEmbeddings
            }
        } catch {
            print("Exception in runModel: \(error.localizedDescription)")
        }

        return nil
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

//    func cropRectFromBitmap(_ image: UIImage, boundingBox: CGRect) -> UIImage? {
//        let scale = image.scale
//        let cropRect = CGRect(
//            x: boundingBox.origin.x * image.size.width,
//            y: (1 - boundingBox.origin.y - boundingBox.size.height) * image.size.height,
//            width: boundingBox.size.width * image.size.width,
//            height: boundingBox.size.height * image.size.height
//        )
//
//        guard let cgImage = image.cgImage?.cropping(to: cropRect) else {
//            return nil
//        }
//
//        return UIImage(cgImage: cgImage, scale: scale, orientation: image.imageOrientation)
//    }
//
    private func cropRectFromBitmap(image: UIImage, toRect rect: CGRect) -> UIImage? {
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
    
    
    // Example implementation of the AchalaSecureCallback protocol
    class ComparisonHandler: AchalaSecureCallback {
        
        weak var viewController: CameraViewController? // Reference to the view controller
           
           init(viewController: CameraViewController) {
               self.viewController = viewController
           }
           
        
        func onCompareSuccess(result: String, score: String, capturedImage: UIImage) {
            
            let resultModel = AchalaSecureResultModel(score: score, bitmapResultData: capturedImage.pngData(), status: "SUCCESS", message: "Face Authentication Successful")
                   
                   // Pass this model to the onFaceDetection closure
            viewController?.faceResult?(resultModel)
            
           viewController?.stopCaptureSessionAndShowAlert(dialogTitle: "Comparison Successful",
                                                           dialogMessage: "Match Found! The comparison was successful.\n Score: \(score)")
            self.viewController?.dismiss(animated:true)
            //print("Comparison Successful! Result: \(result), Score: \(score)")
        }
        
        func onCompareFailed(failed: String,score: String) {
            
            let resultModel = AchalaSecureResultModel(score: score, bitmapResultData: nil, status: "Failed", message: "Face Authentication Failed")
                   
                   // Pass this model to the onFaceDetection closure
            viewController?.faceResult?(resultModel)
            
            viewController?.stopCaptureSessionAndShowAlert(dialogTitle: "Comparison Failed",
                                                          dialogMessage: "No Match Found! The comparison was failed.")
            //print("Comparison Failed! Reason: \(failed)")
        }
    }
    
    func convertToVNFaceObservation(face: Face, imageSize: CGSize) -> VNFaceObservation? {
        // Assuming 'face.frame' is a CGRect representing the bounding box of the face
        let boundingBox = face.frame // CGRect of the face

        // Normalize the bounding box to Vision's coordinate system (0-1 range)
        let normalizedX = boundingBox.origin.x / imageSize.width
        let normalizedY = 1.0 - (boundingBox.origin.y + boundingBox.size.height) / imageSize.height
        let normalizedWidth = boundingBox.size.width / imageSize.width
        let normalizedHeight = boundingBox.size.height / imageSize.height

        // Create and return a VNFaceObservation using the normalized coordinates
        let normalizedBoundingBox = CGRect(x: normalizedX, y: normalizedY, width: normalizedWidth, height: normalizedHeight)

        // Return the VNFaceObservation instance
        return VNFaceObservation(boundingBox: normalizedBoundingBox)
    }
    
    
    func stopCaptureSessionAndShowAlert(dialogTitle: String , dialogMessage: String ) {
          // Stop the capture session
        stopCameraSessionAndReturn()
          
          // Display the alert
        let alert = UIAlertController(title: dialogTitle,
                                      message: dialogMessage,
                                        preferredStyle: .alert)
          
          // Add the OK button
          alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
              print("OK Button tapped")
          }))
          
          // Present the alert
          //present(alert, animated: true, completion: nil)
      }
    // Method to stop the session and return to the previous view
    private func stopCameraSessionAndReturn() {
        // Stop the capture session
        captureSession?.stopRunning()
        
        // Remove the video preview layer
        videoPreviewLayer?.removeFromSuperlayer()
        videoPreviewLayer = nil
        
        // Optionally, you can set capture session to nil to release it
        captureSession = nil
        
        // If using navigation controller, pop back to previous view
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        }
        
        // Or if using presentation (like modally), dismiss the view
        else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    // Create a custom function to show the dialog
    func showAchalaSecureResultDialog(on viewController: UIViewController, with resultModel: AchalaSecureResultModel) {
        let alertController = UIAlertController(title: "Achala Secure Result", message: "", preferredStyle: .alert)

        // Create a view for custom content
        let dialogContentView = UIView()
        dialogContentView.translatesAutoresizingMaskIntoConstraints = false

        // Add ImageView for the BitmapResult (image)
        if let bitmapResult = resultModel.getBitmapResult() {
            let imageView = UIImageView(image: bitmapResult)
            imageView.contentMode = .scaleAspectFit
            imageView.translatesAutoresizingMaskIntoConstraints = false
            dialogContentView.addSubview(imageView)
            
            // ImageView constraints
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: dialogContentView.topAnchor),
                imageView.centerXAnchor.constraint(equalTo: dialogContentView.centerXAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 100),
                imageView.heightAnchor.constraint(equalToConstant: 100)
            ])
        }

        // Add Score
        if let score = resultModel.getScore() {
            let scoreLabel = UILabel()
            scoreLabel.text = "Score: \(score)"
            scoreLabel.font = UIFont.boldSystemFont(ofSize: 16)
            scoreLabel.textColor = .black
            scoreLabel.translatesAutoresizingMaskIntoConstraints = false
            dialogContentView.addSubview(scoreLabel)
            
            // Score label constraints
            NSLayoutConstraint.activate([
                scoreLabel.topAnchor.constraint(equalTo: dialogContentView.topAnchor, constant: 110),
                scoreLabel.centerXAnchor.constraint(equalTo: dialogContentView.centerXAnchor)
            ])
        }

        // Add Status
        if let status = resultModel.getStatus() {
            let statusLabel = UILabel()
            statusLabel.text = "Status: \(status)"
            statusLabel.font = UIFont.systemFont(ofSize: 14)
            statusLabel.textColor = .darkGray
            statusLabel.translatesAutoresizingMaskIntoConstraints = false
            dialogContentView.addSubview(statusLabel)
            
            // Status label constraints
            NSLayoutConstraint.activate([
                statusLabel.topAnchor.constraint(equalTo: dialogContentView.topAnchor, constant: 140),
                statusLabel.centerXAnchor.constraint(equalTo: dialogContentView.centerXAnchor)
            ])
        }

        // Add Message
        if let message = resultModel.getMessage() {
            let messageLabel = UILabel()
            messageLabel.text = message
            messageLabel.font = UIFont.systemFont(ofSize: 14)
            messageLabel.textColor = .black
            messageLabel.numberOfLines = 0
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            dialogContentView.addSubview(messageLabel)
            
            // Message label constraints
            NSLayoutConstraint.activate([
                messageLabel.topAnchor.constraint(equalTo: dialogContentView.topAnchor, constant: 170),
                messageLabel.leftAnchor.constraint(equalTo: dialogContentView.leftAnchor, constant: 20),
                messageLabel.rightAnchor.constraint(equalTo: dialogContentView.rightAnchor, constant: -20),
            ])
        }

        // Add the custom content view to the UIAlertController
        alertController.view.addSubview(dialogContentView)
        
        // Custom view constraints
        NSLayoutConstraint.activate([
            dialogContentView.widthAnchor.constraint(equalToConstant: 250),
            dialogContentView.heightAnchor.constraint(equalToConstant: 300)
        ])

        // Add the "OK" button to the alert
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)

        // Present the alert
        viewController.present(alertController, animated: true, completion: nil)
    }
    // Assuming 'face' is a VNFaceObservation object
    func detectEyesOpen(face: Face) -> Bool {
        // Get left and right eye open probabilities
        let leftEyeProb = face.leftEyeOpenProbability
        let rightEyeProb = face.rightEyeOpenProbability
        
        // Check if the probabilities are valid (not -1.0)
        if leftEyeProb != -1.0 && rightEyeProb != -1.0 {
            if leftEyeProb >= 0.95 && rightEyeProb >= 0.95 {
                print("Eyes are open. " +  "\(leftEyeProb)" +  "\(rightEyeProb)" )
                // Update detection results or perform other necessary actions
                return true // Eyes are open
            } else {
                print("Eyes are not open.")
                return false
            }
        } else {
            print("Eye open probability could not be determined.")
        }
        return false
    }
    
    private func verifyEmployee(comparation: Comparison, verifyImage: UIImage){
        
        
        let uiImage = verifyImage // Always ensures CGImage is valid
        let visionImage = VisionImage(image: uiImage)
        visionImage.orientation = .up
        
        let options = FaceDetectorOptions()
        options.performanceMode = .accurate
        options.landmarkMode = .all
        options.contourMode = .all
        options.classificationMode = .all
        
        let faceDetector = FaceDetector.faceDetector(options: options)
        faceDetector.process(visionImage) { [self] faces, error in
            if let error = error {
                print("[ERROR] Face detection failed: \(error.localizedDescription)")
                return
            }
            
            if let faces = faces {
                
                print("[LOG] \(faces.count) face(s) detected.")
                self.onFaceDetection?(faces.count)
                //self.drawFaces(faces, onImage: uiImage)
                if(faces.count == 1 && detectEyesOpen(face: faces[0])){
                    let frame = faces[0].frame
                    if let croppedImage = self.cropImage(verifyImage, toRect: frame){
                        comparation.runModel(faces: convertToVNFaceObservation(face: faces[0], imageSize: croppedImage.size)!, cameraFrameBitmap: croppedImage, faceFromProcessor: faces[0])
                    }
                
                       
                }
                
            } else {
                print("[LOG] No faces detected.")
                self.onFaceDetection?(0)
            }
        }
    }
}
