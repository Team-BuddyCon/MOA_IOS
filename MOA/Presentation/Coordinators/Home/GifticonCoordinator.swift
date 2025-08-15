//
//  GifticonCoordinator.swift
//  MOA
//
//  Created by 오원석 on 5/8/25.
//

import UIKit
import PhotosUI
import MLKitBarcodeScanning
import MLKitVision
import Vision

protocol GifticonCoordinatorDelegate: AnyObject {
    func navigateToHomeTab()
}

class GifticonCoordinator: Coordinator, GifticonViewControllerDelegate, GifticonDetailViewControllerDelegate, GifticonDetailMapViewControllerDelegate, GifticonEditViewControllerDelegate, GifticonRegisterViewControllerDelegate {
    var childs: [Coordinator] = []
    
    private var navigationController: UINavigationController
    
    weak var delegate: GifticonCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        
        MOAContainer.shared.registerGifticonDependencies()
    }
    
    deinit {
        MOALogger.logd()
    }
    
    func start() {
        MOALogger.logd()
    }
    
    // MARK: GifticonViewControllerDelegate
    func navigateToGifticonDetail(gifticonId: String) {
        guard let detailVC = MOAContainer.shared.resolve(GifticonDetailViewController.self, arguments: gifticonId, false) else { return }
        detailVC.delegate = self
        navigationController.pushViewController(detailVC, animated: true)
    }
    
    func navigateToGifticonRegister() {
        var configuration = PHPickerConfiguration(photoLibrary: .shared())
        configuration.selectionLimit = 1
        configuration.filter = .images
        
        let pickerVC = PHPickerViewController(configuration: configuration)
        pickerVC.delegate = self
        self.navigationController.present(pickerVC, animated: true)
    }
    
    // MARK: GifticonDetailViewControllerDelegate
    func navigateToFullGifticonImage(image: UIImage?) {
        let fullImageVC = FullGifticonImageViewController(image: image)
        self.navigationController.present(fullImageVC, animated: true)
    }
    
    func navigateToGifticonDetailMap(searchPlaces: [SearchPlace], storeType: StoreType) {
        guard let gifticonMapVC = MOAContainer.shared.resolve(GifticonDetailMapViewController.self, arguments: searchPlaces, storeType) else { return }
        gifticonMapVC.delegate = self
        self.navigationController.pushViewController(gifticonMapVC, animated: true)
    }
    
    func navigateBackFromGifticonDetail() {
        if let _ = self.navigationController.viewControllers.first(where: { $0 is UnAvailableGifticonViewController }) {
            navigateBack()
        } else {
            navigateToHomeTab()
        }
    }
    
    func navigateToHomeTab() {
        self.delegate?.navigateToHomeTab()
    }
    
    func navigateToGifticonEdit(gifticon: GifticonModel, image: UIImage?) {
        guard let editVC = MOAContainer.shared.resolve(GifticonEditViewController.self, arguments: gifticon, image) else { return }
        editVC.delegate = self
        self.navigationController.pushViewController(editVC, animated: false)
    }
    
    // MARK: GifticonDetailMapViewControllerDelegate
    func navigateBack() {
        self.navigationController.popViewController(animated: false)
    }
    
    
    // MARK: GifticonRegisterViewControllerDelegate
    func navigateRegisterLoading() {
        guard let loadingVC = MOAContainer.shared.resolve(RegisterLoadingViewController.self) else { return }
        self.navigationController.present(loadingVC, animated: false)
    }
    
    func navigateToGifticonDetail(gifticonId: String, isRegistered: Bool) {
        guard let detailVC = MOAContainer.shared.resolve(GifticonDetailViewController.self, arguments: gifticonId, isRegistered) else { return }
        detailVC.delegate = self
        self.navigationController.pushViewController(detailVC, animated: true)
    }
}

// MARK: PHPickerViewControllerDelegate
extension GifticonCoordinator: PHPickerViewControllerDelegate {
    /// Handles the PHPicker result, dismissing the picker, loading the first selected UIImage (if available), and routing the loaded image into the coordinator's image analysis flow.
    /// 
    /// If image loading fails, presents a modal alert describing a non-barcode-image error. If an image is successfully loaded, calls `imageAnalysis(image:)` on the coordinator to continue OCR/barcode processing.
    /// - Parameters:
    ///   - picker: The PHPickerViewController instance that finished picking.
    ///   - results: An array of PHPickerResult produced by the picker; only the first result is used.
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        MOALogger.logd()
        picker.dismiss(animated: true)
        
        if let itemProvider = results.first?.itemProvider,
           itemProvider.canLoadObject(ofClass: UIImage.self) {
            itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                guard let self = self else {
                    MOALogger.loge()
                    return
                }
                
                if error != nil {
                    MOALogger.loge("PHPicker load Image error: \(String(describing: error?.localizedDescription))")
                    let modalVC = ModalViewController(
                        modalType: .alertDetail,
                        title: GIFTICON_REGISTER_NOT_BARCODE_IMAGE_ERROR_TITLE,
                        subTitle: GIFTICON_REGISTER_NOT_BARCODE_IMAGE_ERROR_SUBTITLE,
                        confirmText: CONFIRM
                    )
                    navigationController.present(modalVC, animated: true)
                    return
                }
                
                imageAnalysis(image: image as? UIImage)
            }
        }
    }
    
    /// Analyze a picked image for barcode/receipt data and navigate to the register flow or show an error.
    /// 
    /// If `image` is nil, presents an alert modal indicating the image is not a valid barcode/receipt image.
    /// Otherwise, calls `checkBarcodeImage` which on error presents the same alert. On success, runs OCR (`operateOCR`) to extract recognized text, then:
    /// - extracts the first date found (tries two formats) and converts it to `Date` as `expireDate` if possible,
    /// - extracts the first store type found and maps it to `StoreType` if possible,
    /// - resolves `GifticonRegisterViewController` with `(image, expireDate, storeType)`, sets its delegate to the coordinator, and pushes it onto the navigation stack.
    /// 
    /// Side effects: may present an alert modal and will push a view controller when OCR parsing succeeds.
    /// - Parameter image: The selected UIImage to analyze; `nil` triggers an error modal.
    private func imageAnalysis(image: UIImage?) {
        guard let image = image else {
            MOALogger.loge("PHPicker load Image is nil")
            let modalVC = ModalViewController(
                modalType: .alertDetail,
                title: GIFTICON_REGISTER_NOT_BARCODE_IMAGE_ERROR_TITLE,
                subTitle: GIFTICON_REGISTER_NOT_BARCODE_IMAGE_ERROR_SUBTITLE,
                confirmText: CONFIRM
            )
            navigationController.present(modalVC, animated: true)
            return
        }
        
        checkBarcodeImage(
            image,
            onError: { [weak self] error in
                let modalVC = ModalViewController(
                    modalType: .alertDetail,
                    title: GIFTICON_REGISTER_NOT_BARCODE_IMAGE_ERROR_TITLE,
                    subTitle: GIFTICON_REGISTER_NOT_BARCODE_IMAGE_ERROR_SUBTITLE,
                    confirmText: CONFIRM
                )
                self?.navigationController.present(modalVC, animated: true)
            },
            completion: { [weak self] image in
                operateOCR(image) { recognizedStrings in
                    guard let recognizedStrings = recognizedStrings else {
                        MOALogger.loge("recognizedStrings is nil")
                        return
                    }
                    
                    let date = recognizedStrings.compactMap { Regex<String>.extractDate(str: $0) }.first
                    var expireDate = (date != nil) ? date!.toDate(format: AVAILABLE_GIFTICON_TIME_FORMAT) : nil
                    expireDate = expireDate ?? ((date != nil) ? date!.toDate(format: AVAILABLE_GIFTICON_TIME_FORMAT2) : nil)
                    
                    let type = recognizedStrings.compactMap { Regex<String>.extractStoreType(str: $0) }.first
                    let storeType = (type != nil) ? StoreType(rawValue: type!) : nil
                    
                    guard let registerVC = MOAContainer.shared.resolve(GifticonRegisterViewController.self, arguments: image, expireDate, storeType) else { return }
                    registerVC.delegate = self
                    self?.navigationController.pushViewController(registerVC, animated: true)
                }
            }
        )
    }
}
