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
