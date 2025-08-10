//
//  NicknameViewController.swift
//  MOUP
//
//  Created by 송규섭 on 8/10/25.
//

import UIKit

class NicknameViewController: UIViewController {
    // MARK: - Properties
    private let nicknameView = NicknameView()

    // MARK: - loadView
    override func loadView() {
        view = nicknameView
    }

    // MARK: - Initializer
    override func viewDidLoad() {
        super.viewDidLoad()

        configure()
    }

}

private extension NicknameViewController {
    // MARK: - configure
    func configure() {
        setBindings()
    }

    // MARK: - setBindings
    func setBindings() {

    }
}
