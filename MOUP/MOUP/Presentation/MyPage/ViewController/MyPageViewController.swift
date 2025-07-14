//
//  MyPageViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit

final class MyPageViewController: UIViewController {
    weak var coordinator: MyPageCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        title = "마이페이지"
    }
}
