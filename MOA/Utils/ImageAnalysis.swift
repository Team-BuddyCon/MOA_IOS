//
//  Untitled.swift
//  MOA
//
//  Created by 오원석 on 8/15/25.
//

import UIKit
import MLKitBarcodeScanning
import MLKitVision
import Vision

/// Checks whether the provided image contains at least one barcode and invokes the appropriate callback.
/// - Parameters:
///   - image: The UIImage to scan for barcodes.
///   - onError: Called if scanning fails or no barcode is found. Receives an optional Error (may be nil). Defaults to a no-op.
///   - completion: Called with the original image when one or more barcodes are successfully detected.
func checkBarcodeImage(
    _ image: UIImage,
    onError: @escaping (Error?) -> Void = { _ in },
    completion: @escaping (UIImage) -> Void
) {
    let barcodeOptions = BarcodeScannerOptions(formats: .all)
    let visionImage = VisionImage(image: image)
    visionImage.orientation = image.imageOrientation
    
    let barcodeScanner = BarcodeScanner.barcodeScanner(options: barcodeOptions)
    barcodeScanner.process(visionImage) { features, error in
        guard error == nil, let features = features, !features.isEmpty else {
            MOALogger.loge("PHPicker image is not contained barcode")
            onError(error)
            return
        }
        
        
        MOALogger.logd("PHPicker image is contained barcode")
        completion(image)
    }
}


/// Performs optical character recognition on the provided image using Vision's text recognizer configured for Korean (ko-KR) with `.accurate` recognition level.
/// - Parameters:
///   - image: The image to analyze. Must contain a valid `cgImage`; if not, the completion will be called with `nil`.
///   - completion: Completion handler invoked with an array of recognized text strings (top candidate per observation) on success, or `nil` if recognition fails.
func operateOCR(
    _ image: UIImage,
    completion: @escaping ([String]?) -> Void
) {
    guard let cgImage = image.cgImage else {
        MOALogger.loge("PHPicker load Image's cgImage doesn't exist")
        completion(nil)
        return
    }
    
    let requestHandler = VNImageRequestHandler(cgImage: cgImage)
    let request = VNRecognizeTextRequest { request, error in
        guard let observation = request.results as? [VNRecognizedTextObservation] else {
            MOALogger.loge("VNRecognozier Text doesn't recognize")
            completion(nil)
            return
        }
        
        let recognizedStrings = observation.compactMap { observation in
            return observation.topCandidates(1).first?.string
        }
        
        MOALogger.logd("VNRecognizeTextRequest success : \(recognizedStrings)")
        completion(recognizedStrings)
    }
    request.recognitionLanguages = ["ko-KR"]
    request.recognitionLevel = .accurate
    
    do {
        try requestHandler.perform([request])
    } catch {
        MOALogger.loge("VNRecognizeTextRequest error happend")
        completion(nil)
    }
}
