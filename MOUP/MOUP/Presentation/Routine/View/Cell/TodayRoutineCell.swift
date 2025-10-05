//
//  TodayRoutineCell.swift
//  MOUP
//
//  Created by 송규섭 on 10/5/25.
//

import UIKit
import SnapKit
import Then

class TodayRoutineCell: UITableViewCell {
    static let identifier = "TodayRoutineCell"

    // MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
}
