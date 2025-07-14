//
//  HomeViewController.swift
//  MOUP
//
//  Created by 서동환 on 7/12/25.
//

import UIKit

final class HomeViewController: UIViewController {
    weak var coordinator: HomeCoordinator?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemRed
        title = "홈"
    }
}

