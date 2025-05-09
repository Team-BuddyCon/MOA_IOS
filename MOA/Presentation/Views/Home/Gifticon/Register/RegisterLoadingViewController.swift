//
//  RegisterLoadingViewController.swift
//  MOA
//
//  Created by 오원석 on 2/16/25.
//

import UIKit
import SnapKit

final class RegisterLoadingViewController: BaseViewController {
    
    private let imageAssets = [
        REGISTER_LOADING1_ICON,
        REGISTER_LOADING2_ICON,
        REGISTER_LOADING3_ICON,
        REGISTER_LOADING4_ICON,
        REGISTER_LOADING5_ICON
    ]
    
    private var animateIndex: Int = 1
    var animateWorkItem: DispatchWorkItem?
    
    private let contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: REGISTER_LOADING1_ICON)
        return imageView
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = GIFTICON_REGISTER_LOADING_POPUP_TITLE
        label.font = UIFont(name: pretendard_bold, size: 16.0)
        label.textColor = .grey90
        label.textAlignment = .center
        return label
    }()
    
    private let subTitleLabel: UILabel = {
        let label = UILabel()
        label.text = GIFTICON_REGISTER_LOADING_POPUP_SUBTITLE
        label.font = UIFont(name: pretendard_regular, size: 12.0)
        label.textColor = .grey70
        label.textAlignment = .center
        return label
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
        modalTransitionStyle = .crossDissolve
    }
    
    deinit {
        animateWorkItem?.cancel()
        animateWorkItem = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        makeAnimation()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        startAnimation()
    }
    
    @MainActor required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

private extension RegisterLoadingViewController {
    func setupLayout() {
        view.backgroundColor = .black.withAlphaComponent(0.5)
        contentView.layer.cornerRadius = 20
        
        [
            iconImageView,
            titleLabel,
            subTitleLabel
        ].forEach {
            contentView.addSubview($0)
        }
        
        view.addSubview(contentView)
        
        contentView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.horizontalEdges.equalToSuperview().inset(38)
            $0.height.equalTo(220)
        }
        
        iconImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().inset(41.5)
            $0.size.equalTo(70)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
    }
    
    func startAnimation() {
        if let workItem = animateWorkItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: workItem)
        }
    }
    
    func makeAnimation() {
        animateWorkItem = DispatchWorkItem { [weak self] in
            UIView.animate(
                withDuration: 0.0,
                delay: 0.0,
                options: [.transitionCrossDissolve]
            ) { [weak self] in
                guard let self = self else { return }
                animateIndex = (animateIndex + 1) % imageAssets.count
                iconImageView.image = UIImage(named: imageAssets[animateIndex])
            }
            
            self?.startAnimation()
        }
    }
}
