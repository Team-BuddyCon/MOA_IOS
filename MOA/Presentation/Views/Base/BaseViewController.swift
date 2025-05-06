//
//  BaseViewController.swift
//  MOA
//
//  Created by 오원석 on 8/14/24.
//

import UIKit
import RxSwift

public class BaseViewController: UIViewController {
    let disposeBag = DisposeBag()
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
}
