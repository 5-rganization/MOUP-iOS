//
//  WorkerSelectView.swift
//  MOUP
//
//  Created by 서동환 on 8/16/26.
//

import SwiftUI

/// 근무자 선택 화면 (사장님 전용)
///
/// 한 번에 여러 근무자에게 같은 근무를 등록할 수 있으므로 다중 선택이다.
/// `WorkplaceSelectView`와 마찬가지로 "적용하기"를 눌러야 선택 결과가 Binding에 반영된다.
struct WorkerSelectView: View {

    // MARK: - Properties

    @Environment(\.dismiss) private var dismiss

    private let workers: [WorkerSummary]
    @Binding private var selectedWorkers: [WorkerSummary]

    @State private var tempSelectedIds: Set<Int>

    // MARK: - Initializer

    /// 새로운 `WorkerSelectView`를 생성합니다.
    ///
    /// - Parameters:
    ///   - workers: 선택 가능한 근무자 목록입니다.
    ///   - selectedWorkers: 부모 뷰와 연결되어 선택 결과를 양방향으로 공유할 바인딩(`@Binding`)입니다.
    init(workers: [WorkerSummary], selectedWorkers: Binding<[WorkerSummary]>) {
        self.workers = workers
        self._selectedWorkers = selectedWorkers
        self._tempSelectedIds = State(initialValue: Set(selectedWorkers.wrappedValue.map { $0.id }))
    }

    // MARK: - UI Components

    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("근무할 근무자를 선택해 주세요")
                .font(.headBold(18))
                .foregroundColor(.gray900)
                .padding(.top, 20)

            VStack(spacing: 12) {
                ForEach(workers, id: \.id) { worker in
                    CheckButtonView(
                        title: worker.nickname,
                        isSelected: binding(for: worker.id)
                    )
                }
            }

            Spacer()
        }
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Content

    var body: some View {
        VStack(spacing: 0) {
            BaseNavigationBarSU(title: "근무자 선택", onBackTap: {
                dismiss()
            })

            ViewThatFits(in: .vertical) {
                content

                ScrollView {
                    content
                }
            }
            .safeAreaInset(edge: .bottom) {
                BaseButtonSU(title: "적용하기") {
                    // 화면에 보이는 순서대로 담아야 "A, B" 표시 순서가 매번 같다.
                    selectedWorkers = workers.filter { tempSelectedIds.contains($0.id) }
                    dismiss()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(.primaryBackground)
                .disabled(tempSelectedIds.isEmpty)
            }
        }
        .background(.primaryBackground)
        .toolbar(.hidden, for: .navigationBar)
        .swipeBackEnabled()
    }
}

// MARK: - Private Methods

private extension WorkerSelectView {
    /// 다중 선택을 위한 Binding 생성
    func binding(for id: Int) -> Binding<Bool> {
        Binding<Bool>(
            get: { tempSelectedIds.contains(id) },
            set: { isSelected in
                if isSelected {
                    tempSelectedIds.insert(id)
                } else {
                    tempSelectedIds.remove(id)
                }
            }
        )
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var selected: [WorkerSummary] = []

        private let workers: [WorkerSummary] = [
            WorkerSummary(id: 1, workerBasedLabelColorStr: nil, ownerBasedLabelColorStr: nil, nickname: "김알바", profileImg: nil),
            WorkerSummary(id: 2, workerBasedLabelColorStr: nil, ownerBasedLabelColorStr: nil, nickname: "이알바", profileImg: nil),
            WorkerSummary(id: 3, workerBasedLabelColorStr: nil, ownerBasedLabelColorStr: nil, nickname: "박알바", profileImg: nil)
        ]

        var body: some View {
            NavigationStack {
                WorkerSelectView(workers: workers, selectedWorkers: $selected)
            }
        }
    }
    return Wrapper()
}
