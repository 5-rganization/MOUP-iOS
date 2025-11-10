//
//  RadioButtonView.swift
//  MOUP
//
//  Created by 양원식 on 7/29/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

enum RadioButtonType {
    case icon(
        selectedIcon: UIImage,
        unselectedIcon: UIImage,
        selectedRadioButton: UIImage,
        unselectedRadioButton: UIImage
    )
    case colorDot(
        UIColor,
        selectedRadioButton: UIImage,
        unselectedRadioButton: UIImage
    )
    case none(
        selectedRadioButton: UIImage,
        unselectedRadioButton: UIImage?
    )
}

final class RadioButtonView: UIView {
    // MARK: - Properties
    private let tapRelay = PublishRelay<Void>()
    private let containerView = UIView()
    private let iconImageView = UIImageView()
    private let colorDotView = UIView().then {
        $0.backgroundColor = .labelRed
        $0.layer.cornerRadius = 6
        $0.clipsToBounds = true
    }
    private let circleImageView = UIImageView()

    private let titleLabel = UILabel().then {
        $0.font = .bodyMedium(16)
        $0.textColor = .gray900
    }

    private var type: RadioButtonType?
    private var isSelectedState: Bool = false

    // MARK: - Initializer
    init(title: String, type: RadioButtonType) {
        super.init(frame: .zero)
        self.titleLabel.text = title
        self.type = type
        configure(type: type)
        setGesture()
    }

    @available(*, unavailable, message: "Use init(title:type:) instead")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }

    // MARK: - Public Methods
    func setSelected(_ selected: Bool) {
        self.isSelectedState = selected
        if let type = self.type {
            setStyles(type: type)
        }
    }

    var tap: Observable<Void> {
        tapRelay.asObservable()
    }
}

// MARK: - Private Methods
private extension RadioButtonView {
    func configure(type: RadioButtonType) {
        setHierarchy(type: type)
        setStyles(type: type)
        setConstraints(type: type)
    }

    func setGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTap))
        self.addGestureRecognizer(tapGesture)
        self.isUserInteractionEnabled = true
    }

    @objc func didTap() {
        tapRelay.accept(())
    }

    func setHierarchy(type: RadioButtonType) {
        addSubview(containerView)

        switch type {
        case .icon:
            containerView.addSubviews(iconImageView, titleLabel, circleImageView)
        case .colorDot:
            containerView.addSubviews(colorDotView, titleLabel, circleImageView)
        case .none:
            containerView.addSubviews(titleLabel, circleImageView)
        }
    }

    func setStyles(type: RadioButtonType) {
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = isSelectedState ? 2 : 1
        containerView.layer.borderColor = isSelectedState ? UIColor.primary500.cgColor : UIColor.gray400.cgColor
        containerView.backgroundColor = .white

        circleImageView.contentMode = .scaleAspectFit
        titleLabel.textColor = isSelectedState ? .primary600 : .gray900
        titleLabel.font = isSelectedState ? .headBold(16) : .bodyMedium(16)

        switch type {
        case let .icon(selectedIcon, unselectedIcon, selectedRadio, unselectedRadio):
            iconImageView.image = isSelectedState ? selectedIcon : unselectedIcon
            circleImageView.image = isSelectedState ? selectedRadio : unselectedRadio

        case let .colorDot(color, selectedRadio, unselectedRadio):
            colorDotView.backgroundColor = color
            circleImageView.image = isSelectedState ? selectedRadio : unselectedRadio

        case let .none(selectedRadio, unselectedRadio):
            circleImageView.image = isSelectedState ? selectedRadio : unselectedRadio
        }
    }

    func setConstraints(type: RadioButtonType) {
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(48)
        }

        switch type {
        case .icon:
            iconImageView.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
                $0.size.equalTo(24)
            }
            titleLabel.snp.makeConstraints {
                $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
                $0.centerY.equalToSuperview()
                $0.trailing.lessThanOrEqualTo(circleImageView.snp.leading).offset(-8)
            }
            circleImageView.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
                $0.size.equalTo(20)
            }

        case .colorDot:
            colorDotView.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
                $0.size.equalTo(12)
            }
            titleLabel.snp.makeConstraints {
                $0.leading.equalTo(colorDotView.snp.trailing).offset(6)
                $0.centerY.equalToSuperview()
                $0.trailing.lessThanOrEqualTo(circleImageView.snp.leading).offset(-8)
            }
            circleImageView.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
                $0.size.equalTo(20)
            }

        case .none:
            titleLabel.snp.makeConstraints {
                $0.leading.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
                $0.trailing.lessThanOrEqualTo(circleImageView.snp.leading).offset(-8)
            }
            circleImageView.snp.makeConstraints {
                $0.trailing.equalToSuperview().inset(16)
                $0.centerY.equalToSuperview()
                $0.size.equalTo(20)
            }
        }
    }
}

// MARK: - Rx Extension
extension Reactive where Base: RadioButtonView {
    var tap: ControlEvent<Void> {
        ControlEvent(events: base.tap)
    }

    var isSelected: Binder<Bool> {
        Binder(base) { view, selected in
            view.setSelected(selected)
        }
    }
}

