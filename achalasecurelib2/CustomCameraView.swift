//import SwiftUI
//import UIKit
//import AVFoundation
//import MLKitFaceDetection
//import MLKitVision
//import Vision
//
//struct ContentView1: View {
//    @State private var isCameraPresented = false
//    @State private var isVerifyUser = false
//    @State private var isImagePickerPresented = false
//    @State private var detectedFacesCount: Int? = nil
//    @State private var selectedImage: UIImage? = nil
//    @State private var recognitionResult: AchalaSecureResultModel? = nil
//    
//    @Environment(\.dismiss) var dismiss  // Dismiss action to go back
//    
////    var body: some View {
////        NavigationView{
////
////                VStack(spacing: 20) {
////                    Button(action: {
////                        isCameraPresented = true
////                    }) {
////                        Text("Open Camera")
////                            .font(.headline)
////                            .padding()
////                            .foregroundColor(.white)
////                            .background(Color.blue)
////                            .cornerRadius(10)
////                    }
////                    .fullScreenCover(isPresented: $isCameraPresented) {
////                        CameraView1(isPresented: $isCameraPresented, onFaceDetection: handleFaceDetection,faceResult:handleFaceResult, verifyUser : selectedImage, isVerifyUser:isVerifyUser)
////                    }
////
////                    Button(action: {
////                        isImagePickerPresented = true
////                    }) {
////                        Text("Pick an Image")
////                            .font(.headline)
////                            .padding()
////                            .foregroundColor(.white)
////                            .background(Color.green)
////                            .cornerRadius(10)
////                    }
////                    .sheet(isPresented: $isImagePickerPresented) {
////                        ImagePicker(image: $selectedImage, onFaceDetection: handleFaceDetection)
////                    }
////
////                    if let count = detectedFacesCount {
////                        Text("Detected Faces: \(count)")
////                            .font(.headline)
////                            .foregroundColor(count > 0 ? .green : .red)
////                    }
////                    if let result = recognitionResult {
////                        VStack(alignment: .leading, spacing: 15) {
////                            if let score = result.score {
////                                Text("Score: \(score)")
////                                    .font(.title2)
////                                    .fontWeight(.bold)
////                                    .foregroundColor(.blue)
////                                    .padding(.bottom, 5)
////                            }
////
////                            if let status = result.status {
////                                Text("Status: \(status)")
////                                    .font(.headline)
////                                    .foregroundColor(.gray)
////                                    .padding(.bottom, 5)
////                            }
////
////                            if let message = result.message {
////                                Text("Message:")
////                                    .font(.body)
////                                    .foregroundColor(.black)
////                                    .fontWeight(.medium)
////                                Text(message)
////                                    .font(.body)
////                                    .foregroundColor(.black)
////                                    .padding(.top, 5)
////                            }
////
////                            if let image = result.bitmapResult {
////                                Image(uiImage: image)
////                                    .resizable()
////                                    .scaledToFit()
////                                    .frame(width: 150, height: 150)
////                                    .clipShape(RoundedRectangle(cornerRadius: 10))
////                                    .shadow(radius: 5)
////                                    .padding(.top, 15)
////                            }
////                        }
////                        .padding()
////                        .background(Color.white)
////                        .cornerRadius(15)
////                        .shadow(radius: 10)
////                        .padding(.top, 20)
////                        .padding([.leading, .trailing], 20)
////                    }
////
////
////                }
////                .navigationBarBackButtonHidden(true) // Hide default back button
////                .toolbar {
////                    ToolbarItem(placement: .navigationBarLeading) { // Place button in the top-left
////                        Button(action: {
////                            dismiss()  // Go back to the previous screen
////                        }) {
////                            HStack {
////                                Image(systemName: "chevron.left") // Back arrow icon
////                                Text("Back")
////                            }
////                        }
////                    }
////                }
////                .padding()
////        }.navigationTitle("Camera Screen")
////    }
////
////    private func handleFaceDetection(facesCount: Int) {
////        detectedFacesCount = facesCount
////    }
////    private func handleFaceResult(model: AchalaSecureResultModel) {
////          recognitionResult = model
////
////      }
//    var body: some View{
//        return EmptyView()
//    }
//}
//
//struct ImagePicker: UIViewControllerRepresentable {
//    @Environment(\.presentationMode) var presentationMode
//    @Binding var image: UIImage?
//    var onFaceDetection: (Int) -> Void
//
//    func makeUIViewController(context: Context) -> UIImagePickerController {
//        let picker = UIImagePickerController()
//        picker.delegate = context.coordinator
//        picker.sourceType = .photoLibrary
//        picker.allowsEditing = false
//        return picker
//    }
//
//    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
//
//    func makeCoordinator() -> Coordinator {
//        Coordinator(self)
//    }
//
//    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
//        let parent: ImagePicker
//
//        init(_ parent: ImagePicker) {
//            self.parent = parent
//        }
//
//        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
//            if let selectedImage = info[.originalImage] as? UIImage {
//                parent.image = selectedImage
//                detectFaces(in: selectedImage)
//            }
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//
//        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//            parent.presentationMode.wrappedValue.dismiss()
//        }
//
//        private func detectFaces(in image: UIImage) {
//            let visionImage = VisionImage(image: image)
//            visionImage.orientation = image.imageOrientation
//
//            let options = FaceDetectorOptions()
//            options.performanceMode = .accurate
//            options.landmarkMode = .all
//            options.contourMode = .all
//            options.classificationMode = .all
//
//            let faceDetector = FaceDetector.faceDetector(options: options)
//            faceDetector.process(visionImage) { faces, error in
//                if let error = error {
//                    print("[ERROR] Face detection failed: \(error.localizedDescription)")
//                    self.parent.onFaceDetection(0) // Handle as no faces detected
//                    return
//                }
//
//                if let faces = faces {
//                    print("[LOG] \(faces.count) face(s) detected.")
//                    self.parent.onFaceDetection(faces.count)
//                } else {
//                    print("[LOG] No faces detected.")
//                    self.parent.onFaceDetection(0)
//                }
//            }
//        }
//    }
//}
//
////struct CameraView1: UIViewControllerRepresentable {
////    @Binding var isPresented: Bool
////    var onFaceDetection: (Int) -> Void
////    var faceResult: (AchalaSecureResultModel) -> Void
////    var verifyUser : UIImage?
////    var isVerifyUser: Bool?
////
////
////    func makeUIViewController(context: Context) -> CameraViewController {
////        let cameraVC = CameraViewController()
////        cameraVC.onDismiss = {
////            isPresented = false
////        }
////        cameraVC.onFaceDetection = onFaceDetection
////        cameraVC.faceResult = faceResult
////        cameraVC.verifyUser = verifyUser
////        cameraVC.isVerifyUser = isVerifyUser
////
////        return cameraVC
////    }
////
////    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
////
////
////
////    }
////}
//
////public struct CameraView1: UIViewControllerRepresentable {
////    @Binding public var isPresented: Bool
////    public var onFaceDetection: (Int) -> Void
////    public var faceResult: (AchalaSecureResultModel) -> Void
////    public var verifyUser: UIImage?
////    public var isVerifyUser: Bool?
////
////    // Public initializer for external access
////    public init(
////        isPresented: Binding<Bool>,
////        onFaceDetection: @escaping (Int) -> Void,
////        faceResult: @escaping (AchalaSecureResultModel) -> Void,
////        verifyUser: UIImage? = nil,
////        isVerifyUser: Bool? = nil
////    ) {
////        self._isPresented = isPresented
////        self.onFaceDetection = onFaceDetection
////        self.faceResult = faceResult
////        self.verifyUser = verifyUser
////        self.isVerifyUser = isVerifyUser
////    }
////
////    public func makeUIViewController(context: Context) -> CameraViewController {
////        let cameraVC = CameraViewController()
////        cameraVC.onDismiss = {
////            isPresented = false
////        }
////        cameraVC.onFaceDetection = onFaceDetection
////        cameraVC.faceResult = faceResult
////        cameraVC.verifyUser = verifyUser
////        cameraVC.isVerifyUser = isVerifyUser
////        return cameraVC
////    }
////
////    public func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
////        // If you need to update the UI dynamically
////    }
////}
//
//
//
//#Preview {
//    ContentView1()
//}
