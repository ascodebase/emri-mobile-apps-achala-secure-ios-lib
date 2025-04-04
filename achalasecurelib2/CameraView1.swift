//
//  CameraView1.swift
//  achalasecurelib2
//
//  Created by EMRI on 12/02/25.
//

import SwiftUI

public struct CameraView1: UIViewControllerRepresentable {
    @Binding public var isPresented: Bool
    public var onFaceDetection: (Int) -> Void
    public var faceResult: (AchalaSecureResultModel) -> Void
    public var verifyUser: UIImage?
    public var isVerifyUser: Bool?

    public init(
        isPresented: Binding<Bool>,
        onFaceDetection: @escaping (Int) -> Void,
        faceResult: @escaping (AchalaSecureResultModel) -> Void,
        verifyUser: UIImage? = nil,
        isVerifyUser: Bool? = nil
    ) {
        self._isPresented = isPresented
        self.onFaceDetection = onFaceDetection
        self.faceResult = faceResult
        self.verifyUser = verifyUser
        self.isVerifyUser = isVerifyUser
    }

    public func makeUIViewController(context: Context) -> CameraViewController {
        let cameraVC = CameraViewController()
        cameraVC.onDismiss = {
            isPresented = false
        }
        cameraVC.onFaceDetection = onFaceDetection
        cameraVC.faceResult = faceResult
        cameraVC.verifyUser = verifyUser
        cameraVC.isVerifyUser = isVerifyUser
        return cameraVC
    }

    public func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
