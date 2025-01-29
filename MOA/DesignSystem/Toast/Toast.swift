//
//  Toast.swift
//  MOA
//
//  Created by 오원석 on 12/7/24.
//

import UIKit
import RxSwift

final class Toast {
    private let disposeBag = DisposeBag()
    static let shared = Toast()
    private var window: UIWindow?
    
    private let toastView: ToastView = {
        let view = ToastView()
        return view
    }()
    
    private init() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        window = UIWindow(windowScene: windowScene)
        window?.windowLevel = .alert
        window?.addSubview(toastView)
        window?.isUserInteractionEnabled = false
    }
    
    func show(message: String, down: Bool = true) {
        MOALogger.logd("\(message)")
        
        if down {
            toastView.snp.remakeConstraints {
                $0.centerX.equalToSuperview()
                $0.bottom.equalToSuperview().offset(-96)
                $0.height.equalTo(42)
                $0.width.equalTo(216)
            }
        } else {
            toastView.snp.remakeConstraints {
                $0.centerX.equalToSuperview()
                $0.top.equalToSuperview().inset(178)
                $0.height.equalTo(42)
                $0.width.equalTo(216)
            }
        }
        
        toastView.message = message
        window?.makeKeyAndVisible()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.hide()
        }
    }
    
    private func hide() {
        MOALogger.logd()
        window?.isHidden = true
        window?.resignKey()
    }
}
