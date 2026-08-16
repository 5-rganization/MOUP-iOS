//
//  RoleSegmentedView.swift
//  MOUP
//
//  Created by 서동환 on 8/16/26.
//

import SwiftUI

/// 근무 대상(사장님/알바생) 세그먼트 컨트롤
///
/// `OLDRoleSegmentedControl`의 SwiftUI 버전이다. 기본 `.pickerStyle(.segmented)`는 앱 스타일과 달라 직접 그린다.
struct RoleSegmentedView: View {

    // MARK: - Properties

    @Binding private var selection: WorkerWorkForm.Target

    private let targets: [WorkerWorkForm.Target] = [.owner, .worker]

    // MARK: - Initializer

    init(selection: Binding<WorkerWorkForm.Target>) {
        self._selection = selection
    }

    // MARK: - Content

    var body: some View {
        HStack(spacing: 0) {
            ForEach(targets, id: \.self) { target in
                let isSelected = selection == target

                Button {
                    selection = target
                } label: {
                    Text(title(for: target))
                        .font(isSelected ? .headBold(16) : .bodyMedium(16))
                        .foregroundStyle(isSelected ? .primary500 : .gray500)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(isSelected ? Color.white : .clear)
                                .padding(4)
                        )
                        .contentShape(Rectangle())
                }
                .buttonStyle(FormRowButtonStyle())
            }
        }
        .frame(height: 48)
        .background(.gray300)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Private Methods

private extension RoleSegmentedView {
    func title(for target: WorkerWorkForm.Target) -> String {
        switch target {
        case .owner: return UserRole.owner.displayStr
        case .worker: return UserRole.worker.displayStr
        }
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var selection: WorkerWorkForm.Target = .owner

        var body: some View {
            RoleSegmentedView(selection: $selection)
                .padding(.horizontal, 16)
        }
    }
    return Wrapper()
}
