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
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        MOALogger.logd()
        picker.dismiss(animated: true)
        
        let itemProvider = results.first?.itemProvider
        if let itemProvider = itemProvider,
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
                
                checkBarcodeImage(image: image as? UIImage)
            }
        }
    }
    
    private func checkBarcodeImage(image: UIImage?) {
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
        
        let barcodeOptions = BarcodeScannerOptions()
        let visionImage = VisionImage(image: image)
        visionImage.orientation = image.imageOrientation
        
        let barcodeScanner = BarcodeScanner.barcodeScanner(options: barcodeOptions)
        barcodeScanner.process(visionImage) { [weak self] features, error in
            guard let self = self else {
                MOALogger.loge()
                return
            }
            
            guard error == nil, let features = features, !features.isEmpty else {
                MOALogger.loge("PHPicker image is not contained barcode")
                let modalVC = ModalViewController(
                    modalType: .alertDetail,
                    title: GIFTICON_REGISTER_NOT_BARCODE_IMAGE_ERROR_TITLE,
                    subTitle: GIFTICON_REGISTER_NOT_BARCODE_IMAGE_ERROR_SUBTITLE,
                    confirmText: CONFIRM
                )
                navigationController.present(modalVC, animated: true)
                return
            }
            
            MOALogger.logd()
            
            guard let registerVC = MOAContainer.shared.resolve(GifticonRegisterViewController.self, argument: image) else { return }
            registerVC.delegate = self
            navigationController.pushViewController(registerVC, animated: true)
        }
    }
}
