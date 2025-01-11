//
//  PolicyWebViewController.swift
//  MOA
//
//  Created by 오원석 on 1/12/25.
//

import UIKit
import SnapKit
import WebKit

final class PolicyWebViewController: BaseViewController {
    private let usePolicyWebView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    private let privacyPolicyWebView: WKWebView = {
        let configuration = WKWebViewConfiguration()
        let webView = WKWebView(frame: .zero, configuration: configuration)
        return webView
    }()
    
    private let policyUrl: String
    private let privacyUrl: String
    
    init(policyUrl: String, privacyUrl: String) {
        self.policyUrl = policyUrl
        self.privacyUrl = privacyUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MOALogger.logd()
        setupLayout()
        loadWebView()
    }
    
    private func setupLayout() {
        setupTopBarWithBackButton(title: MOA_TERMS_POLICY_TITLE)
        
        view.addSubview(usePolicyWebView)
        view.addSubview(privacyPolicyWebView)
        
        usePolicyWebView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.snp.centerY)
        }
        
        privacyPolicyWebView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.top.equalTo(view.snp.centerY)
        }
    }
    
    private func loadWebView() {
        let usePolicyUrlComponents = URLComponents(string: policyUrl)
        if let url = usePolicyUrlComponents?.url {
            usePolicyWebView.load(URLRequest(url: url))
        }
        
        let privacyPolicyUrlComponents = URLComponents(string: privacyUrl)
        if let url = privacyPolicyUrlComponents?.url {
            privacyPolicyWebView.load(URLRequest(url: url))
        }
    }
}
