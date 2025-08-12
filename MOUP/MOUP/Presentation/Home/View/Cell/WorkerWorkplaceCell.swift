//
//  WorkerWorkplaceCell.swift
//  MOUP
//
//  Created by 송규섭 on 8/1/25.
//

import UIKit

class WorkerWorkplaceCell: UITableViewCell {
    // MARK: - Properties
    static let identifier = "WorkerWorkplaceCell"

    // MARK: - UI Components
    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configure()
    }

    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
    func update(item: HomeSectionItem) {
        switch item {
        case .worker(let workerInfo):
            self.titleLabel.text = workerInfo.workplace.name
        case .owner:
            break
        }
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
        addSubviews(titleLabel)
    }

    // MARK: - setStyles
    func setStyles() {
        
    }

    // MARK: - setConstraints
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
