//
//  ColorLabelContainerView.swift
//  MOUP
//
//  Created by 양원식 on 7/19/25.
//
import UIKit
import SnapKit
import Then

final class ColorLabelContainerView: UIView {
    // MARK: - Properties
    private let container = ContainerView()
    
    private let colorLabelInfoRow = InfoRowView(title: "", type: .colorWithChevron(color: .labelRed, title: "빨간색"), frame: .zero)
    
    // MARK: - UI Components
    
    // MARK: - 라벨 타이틀
    private let colorLabelTitle = UILabel().then {
        let fullText = "라벨 *"
        let attributed = NSMutableAttributedString(string: fullText)

        attributed.addAttribute(.font, value: UIFont.headBold(18), range: NSRange(location: 0, length: fullText.count))
        attributed.addAttribute(.foregroundColor, value: UIColor.gray900, range: NSRange(location: 0, length: fullText.count))

        if let starRange = fullText.range(of: "*") {
            let nsRange = NSRange(starRange, in: fullText)
            attributed.addAttribute(.foregroundColor, value: UIColor.accent, range: nsRange)
        }

        $0.attributedText = attributed
    }
    
    // MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Public Methods
}

private extension ColorLabelContainerView {
    // MARK: - configure
    func configure() {
        setHierarchy()
        setStyles()
        setConstraints()
    }
    
    // MARK: - setHierarchy
    func setHierarchy() {
        addSubviews(
            colorLabelTitle,
            container
        )
        
        container.addSubviews(
            colorLabelInfoRow
        )
    }
    
    // MARK: - setStyles
    func setStyles() {
        backgroundColor = .white
    }
    
    // MARK: - setConstraints
    func setConstraints() {
        
        // MARK: - 라벨 타이틀
        colorLabelTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        
        // MARK: - 컨테이너
        container.snp.makeConstraints {
            $0.top.equalTo(colorLabelTitle.snp.bottom).offset(12)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalTo(colorLabelInfoRow.snp.bottom)
        }
        
        // MARK: - 라벨 타이틀
        colorLabelInfoRow.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
        }
        
        self.snp.makeConstraints {
            $0.bottom.equalTo(container.snp.bottom).offset(0)
        }
    }
}

