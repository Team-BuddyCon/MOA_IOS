//
//  MOAContainer.swift
//  MOA
//
//  Created by 오원석 on 6/1/25.
//

import UIKit
import Swinject

struct MOAContainer {
    
    static let shared = MOAContainer()
    
    private let container = Container()
    
    init() {
        registerServices()
    }
    
    func resolve<Service>(_ serviceType: Service.Type) -> Service? {
        container.resolve(serviceType)
    }
    
    func resolve<Service, Arg1>(
        _ serviceType: Service.Type,
        argument: Arg1
    ) -> Service? {
        container.resolve(serviceType, argument: argument)
    }
    
    func resolve<Service, Arg1, Arg2>(
        _ serviceType: Service.Type,
        arguments arg1: Arg1, _ arg2: Arg2
    ) -> Service? {
        container.resolve(serviceType, arguments: arg1, arg2)
    }
    
    func resolve<Service, Arg1, Arg2, Arg3>(
        _ serviceType: Service.Type,
        arguments arg1: Arg1, _ arg2: Arg2, _ arg3: Arg3
    ) -> Service? {
        container.resolve(serviceType, arguments: arg1, arg2, arg3)
    }
    
    private func registerServices() {
        container.register(GifticonServiceProtocol.self) { _ in
            GifticonService.shared
        }
        
        container.register(KakaoServiceProtocol.self) { _ in
            KakaoService.shared
        }
    }
    
    func registerAppDependencies() {
        container.register(SplashViewController.self) { _ in
            SplashViewController()
        }
    }

    func registerAuthDependencies() {
        container.register(WalkThroughViewModel.self) { _ in
            WalkThroughViewModel()
        }
        
        container.register(WalkThroughViewController.self) { r in
            WalkThroughViewController(
                walkThroughViewModel: r.resolve(WalkThroughViewModel.self)!
            )
        }
        
        container.register(LoginViewModel.self) { _ in
            LoginViewModel()
        }
        
        container.register(LoginViewController.self) { (r, isLogout: Bool, isWithDraw: Bool) in
            LoginViewController(
                loginViewModel: r.resolve(LoginViewModel.self)!,
                isLogout: isLogout,
                isWithDraw: isWithDraw
            )
        }
    }
    
    func registerSignUpDependencies() {
        container.register(SignUpViewModel.self) { _ in
            SignUpViewModel()
        }
        
        container.register(SignUpViewController.self) { r in
            SignUpViewController(
                signUpViewModel: r.resolve(SignUpViewModel.self)!
            )
        }
        
        container.register(SignUpWebViewController.self) { (_, title: String, url: String) in
            SignUpWebViewController(title: title, url: url)
        }
        
        container.register(SignUpCompleteViewController.self) { _ in
            SignUpCompleteViewController()
        }
    }
    
    func registerHomeDependencies() {
        container.register(NotificationViewModel.self) { _ in
            NotificationViewModel()
        }
        
        container.register(NotificationViewController.self) { r in
            NotificationViewController(
                viewModel: r.resolve(NotificationViewModel.self)!
            )
        }
    }
    
    func registerGifticonDependencies() {
        container.register(GifticonViewModel.self) { r in
            GifticonViewModel(
                gifticonService: r.resolve(GifticonServiceProtocol.self)!
            )
        }
        
        container.register(GifticonViewController.self) { r in
            GifticonViewController(
                gifticonViewModel: r.resolve(GifticonViewModel.self)!
            )
        }
        
        container.register(GifticonRegisterViewModel.self) { r in
            GifticonRegisterViewModel(
                gifticonService: r.resolve(GifticonServiceProtocol.self)!
            )
        }
        
        container.register(GifticonRegisterViewController.self) { (r, image: UIImage, expireDate: Date?, storeType: StoreType?) in
            GifticonRegisterViewController(
                viewModel: r.resolve(GifticonRegisterViewModel.self)!,
                image: image,
                expireDate: expireDate,
                storeType: storeType
            )
        }
        
        container.register(RegisterLoadingViewController.self) { _ in
            RegisterLoadingViewController()
        }
        
        container.register(GifticonEditViewModel.self) { r in
            GifticonEditViewModel(
                gifticonService: r.resolve(GifticonServiceProtocol.self)!
            )
        }
        
        container.register(GifticonEditViewController.self) { (r, gifticon: GifticonModel, image: UIImage? ) in
            GifticonEditViewController(
                gifticonEditViewModel: r.resolve(GifticonEditViewModel.self)!,
                gifticon: gifticon,
                gifticonImage: image
            )
        }
        
        container.register(GifticonDetailViewModel.self) { r in
            GifticonDetailViewModel(
                gifticonService: r.resolve(GifticonServiceProtocol.self)!,
                kakaoService: r.resolve(KakaoServiceProtocol.self)!
            )
        }
        
        container.register(GifticonDetailViewController.self) { (r, gifticonId: String, isRegistered: Bool) in
            GifticonDetailViewController(
                gifticonDetailViewModel: r.resolve(GifticonDetailViewModel.self)!,
                gifticonId: gifticonId,
                isRegistered: isRegistered
            )
        }
        
        container.register(GifticonDetailMapViewController.self) { (_, searchPlaces: [SearchPlace], storeType: StoreType) in
            GifticonDetailMapViewController(
                searchPlaces: searchPlaces,
                storeType: storeType
            )
        }
    }
    
    func registerMapDependencies() {
        container.register(MapViewModel.self) { r in
            MapViewModel(
                gifticonService: r.resolve(GifticonServiceProtocol.self)!,
                kakaoService: r.resolve(KakaoServiceProtocol.self)!
            )
        }
        
        container.register(MapViewController.self) { r in
            MapViewController(
                mapViewModel: r.resolve(MapViewModel.self)!
            )
        }
    }
    
    func registerMypageDependencies() {
        container.register(MypageViewModel.self) { r in
            MypageViewModel(
                gifticonService: r.resolve(GifticonServiceProtocol.self)!
            )
        }
        
        container.register(MypageViewController.self) { r in
            MypageViewController(
                mypageViewModel: r.resolve(MypageViewModel.self)!
            )
        }
        
        container.register(NotificationSettingViewModel.self) { r in
            NotificationSettingViewModel(
                gifticonService: r.resolve(GifticonServiceProtocol.self)!
            )
        }
        
        container.register(NotificationSettingViewController.self) { r in
            NotificationSettingViewController(
                notificationViewModel: r.resolve(NotificationSettingViewModel.self)!
            )
        }
        
        container.register(PolicyWebViewController.self) { (_, policyUrl: String, privacyUrl: String) in
            PolicyWebViewController(policyUrl: policyUrl, privacyUrl: privacyUrl)
        }
        
        container.register(UnAvailableGifticonViewModel.self) { r in
            UnAvailableGifticonViewModel(
                gifticonService: r.resolve(GifticonServiceProtocol.self)!
            )
        }
        
        container.register(UnAvailableGifticonViewController.self) { r in
            UnAvailableGifticonViewController(
                viewModel: r.resolve(UnAvailableGifticonViewModel.self)!
            )
        }
        
        container.register(VersionViewController.self) { _ in
            VersionViewController()
        }
        
        container.register(WithDrawViewModel.self) { r in
            WithDrawViewModel(
                gifticonService: r.resolve(GifticonServiceProtocol.self)!
            )
        }
        
        container.register(WithDrawViewController.self) { r in
            WithDrawViewController(
                withDrawViewModel: r.resolve(WithDrawViewModel.self)!
            )
        }
    }
}
