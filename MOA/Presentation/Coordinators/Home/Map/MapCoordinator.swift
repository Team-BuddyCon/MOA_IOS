//
//  MapCoordinator.swift
//  MOA
//
//  Created by 오원석 on 5/8/25.
//

import UIKit

protocol MapCoordinatorDelegate: AnyObject {
    func navigateToGifticonDetail(gifticonId: String)
}

class MapCoordinator: Coordinator, MapViewControllerDelegate {
    var childs: [Coordinator] = []
    
    private var navigationController: UINavigationController
    
    weak var delegate: MapCoordinatorDelegate?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        MOALogger.logd()
    }
    
    // MARK: MapViewControllerDelegate
    func navigateToGifticonDetail(gifticonId: String) {
        self.delegate?.navigateToGifticonDetail(gifticonId: gifticonId)
    }
    
    func navigateTpMapStoreBottomSheet(searchPlace: SearchPlace, delegate: MapStoreBottomSheetDelegate) {
        let storeBottomSheetVC = MapStoreBottomSheetViewController()
        storeBottomSheetVC.searchPlace = searchPlace
        storeBottomSheetVC.delegate = delegate
        self.navigationController.present(storeBottomSheetVC, animated: true)
    }
}
