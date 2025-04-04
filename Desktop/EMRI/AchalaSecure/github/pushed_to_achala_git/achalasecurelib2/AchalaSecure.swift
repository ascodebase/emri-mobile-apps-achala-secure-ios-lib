//
//  AchalaSecure.swift
//  achalasecurelib2
//
//  Created by EMRI on 12/02/25.
//

import SwiftUI

public struct AchalaSecure {
    public static func presentCameraView(
        isPresented: Binding<Bool>,
        onFaceDetection: @escaping (Int) -> Void,
        faceResult: @escaping (AchalaSecureResultModel) -> Void,
        verifyUser: UIImage? = nil,
        isVerifyUser: Bool? = nil
    ) -> some View {
        CameraView1(
            isPresented: isPresented,
            onFaceDetection: onFaceDetection,
            faceResult: faceResult,
            verifyUser: verifyUser,
            isVerifyUser: isVerifyUser
        )
    }

//    public static func presentImagePicker(
//        isPresented: Binding<Bool>,
//        selectedImage: Binding<UIImage?>,
//        onFaceDetection: @escaping (Int) -> Void
//    ) -> some View {
//        ImagePicker(image: selectedImage, onFaceDetection: onFaceDetection)
//    }
    
}

//
//import SwiftUI
//import AchalaSecure
//
//struct ContentView: View {
//    @State private var isCameraPresented = false
//    @State private var isImagePickerPresented = false
//    @State private var selectedImage: UIImage? = nil
//    @State private var detectedFacesCount: Int? = nil
//    @State private var recognitionResult: AchalaSecureResultModel? = nil
//
//    var body: some View {
//        VStack(spacing: 20) {
//            Button("Open Camera") {
//                isCameraPresented = true
//            }
//            .sheet(isPresented: $isCameraPresented) {
//                AchalaSecure.presentCameraView(
//                    isPresented: $isCameraPresented,
//                    onFaceDetection: handleFaceDetection,
//                    faceResult: handleFaceResult
//                )
//            }
//
//            Button("Pick an Image") {
//                isImagePickerPresented = true
//            }
//            .sheet(isPresented: $isImagePickerPresented) {
//                AchalaSecure.presentImagePicker(
//                    isPresented: $isImagePickerPresented,
//                    selectedImage: $selectedImage,
//                    onFaceDetection: handleFaceDetection
//                )
//            }
//
//            if let count = detectedFacesCount {
//                Text("Detected Faces: \(count)")
//            }
//
//            if let result = recognitionResult {
//                Text("Score: \(result.getScore() ?? "N/A")")
//                Text("Status: \(result.getStatus() ?? "N/A")")
//                Text("Message: \(result.getMessage() ?? "N/A")")
//            }
//        }
//        .padding()
//    }
//
//    private func handleFaceDetection(facesCount: Int) {
//        detectedFacesCount = facesCount
//    }
//
//    private func handleFaceResult(model: AchalaSecureResultModel) {
//        recognitionResult = model
//    }
//}
