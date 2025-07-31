//
//  WorkerWorkplaceCell.swift
//  MOUP
//
//  Created by 송규섭 on 8/1/25.
//

import UIKit

class WorkerWorkplaceCell: UITableViewCell {
    // MARK: - Properties
    private let identifier = "WorkerWorkplaceCell"

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
}

private extension WorkerWorkplaceCell {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }

    // MARK: - setHierarchy
    func setHierarchy() {

    }

    // MARK: - setStyles
    func setStyles() {

    }

    // MARK: - setConstraints
    func setConstraints() {

    }
}
