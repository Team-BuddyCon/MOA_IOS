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
        
        MOAContainer.shared.registerMapDependencies()
    }
    
    deinit {
        MOALogger.logd()
    }
    
    func start() {
        MOALogger.logd()
    }
    
    // MARK: MapViewControllerDelegate
    func navigateToGifticonDetail(gifticonId: String) {
        self.delegate?.navigateToGifticonDetail(gifticonId: gifticonId)
    }
    
    func navigateToMapLocationBottomSheet(searchPlace: SearchPlace, delegate: BottomSheetViewControllerDelegate) {
        let bottomSheetVC = BottomSheetFactory.create(
            sheetType: BottomSheetType.MapStore(place: searchPlace),
            delegate: delegate
        )
        self.navigationController.present(bottomSheetVC, animated: true)
    }
}
