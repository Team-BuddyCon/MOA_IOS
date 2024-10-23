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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupAppearance()
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
        navigationItem.title = SIGNUP_TITLE
        
        view.addSubview(webView)
        webView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        let urlComponents = URLComponents(string: "https://scarce-cartoon-27d.notion.site/e09da35361e142b7936c12e38396475e")
        if let url = urlComponents?.url {
            webView.load(URLRequest(url: url))
        }
    }
    
    @objc private func tapBackButton() {
        navigationController?.popViewController(animated: true)
    }
}
