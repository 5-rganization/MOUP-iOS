//
//  InviteCodeSheetViewController.swift
//  MOUP
//
//  Created by 송규섭 on 9/28/25.
//

import UIKit
import RxSwift

final class InviteCodeSheetViewController: UIViewController {
    // MARK: - Properties
    private let inviteCodeSheetView = InviteCodeSheetView()
    private let viewModel: InviteCodeSheetViewModel
    private let disposeBag = DisposeBag()
    private let workplaceId: Int
    
    // MARK: - loadView
    override func loadView() {
        view = inviteCodeSheetView
    }
    
    // MARK: - Initializer
    init(viewModel: InviteCodeSheetViewModel, workplaceId: Int) {
        self.viewModel = viewModel
        self.workplaceId = workplaceId
        super.init(nibName: nil, bundle: nil)
    }
    
    @available(*, unavailable, message: "storyboard is not supported.")
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented.")
    }
    
    // MARK: - Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
}

private extension InviteCodeSheetViewController {
    func configure() {
        setBindings()
    }
    
    func setBindings() {
        let input = InviteCodeSheetViewModel.Input(workplaceId: .just(workplaceId))
        let output = viewModel.transform(input: input)
        
        output.inviteCode
            .withUnretained(self)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { owner, code in
                owner.inviteCodeSheetView.update(with: code)
            })
            .disposed(by: disposeBag)
        
        inviteCodeSheetView.rx.copyBtnTapped
            .withLatestFrom(output.inviteCode)
            .withUnretained(self)
            .subscribe(onNext: { owner, code in
                let result = owner.copyToClipboard(code)
                if result { owner.copySuccessed() }
            })
            .disposed(by: disposeBag)
    }
}

private extension InviteCodeSheetViewController {
    func copyToClipboard(_ inviteCode: String) -> Bool {
        UIPasteboard.general.string = inviteCode
        return UIPasteboard.general.string == inviteCode // 클립보드에 제대로 복사됐는지 검증
    }
    
    func copySuccessed() {
        inviteCodeSheetView.applyCopySuccessed()
    }
    
    // 초대 코드 타 앱을 통한 공유 기능 추후 적용 예정
    func shareInviteCode(_ inviteCode: String) {
        let inviteText = "MOUP 앱에서 당신을 근무지에 초대합니다.\n초대 코드를 입력해 입장해주세요!\n초대 코드: \(inviteCode)"
        let activityVC = UIActivityViewController(activityItems: [inviteText], applicationActivities: nil)
        present(activityVC, animated: true)
    }
}
