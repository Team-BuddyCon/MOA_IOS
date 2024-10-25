//
//  SignUpWebViewController.swift
//  MOA
//
//  Created by 오원석 on 10/23/24.
//

import UIKit
import SnapKit
import WebKit

final class SignUpWebViewController: BaseViewController {
    
    private let webView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    private let barTitle: String
    private let webUrl: String
    
    init(title: String, url: String) {
        self.barTitle = title
        self.webUrl = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupAppearance()
        loadWebView()
    }
    
    private func setupAppearance() {
        navigationItem.hidesBackButton = true
        let backButtonItem = UIBarButtonItem(
            image: UIImage(named: BACK_BUTTON_IMAGE_ASSET),
            style: .plain,
            target: self,
            action: #selector(tapBackButton)
        )
        backButtonItem.tintColor = .grey90
        navigationItem.leftBarButtonItem = backButtonItem
        navigationItem.title = barTitle
        
        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.verticalEdges.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    private func loadWebView() {
        let urlComponents = URLComponents(string: webUrl)
        if let url = urlComponents?.url {
            webView.load(URLRequest(url: url))
        }
    }
    
    @objc private func tapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}
