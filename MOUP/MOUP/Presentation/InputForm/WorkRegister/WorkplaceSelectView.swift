//
//  WorkplaceSelectView.swift
//  MOUP
//
//  Created by 서동환 on 3/26/26.
//

import SwiftUI

/// 근무지 선택 화면
///
/// `WorkplaceSummary` 목록을 표시하고, 단일 선택(라디오 방식)으로 근무지를 선택합니다.
/// 임시 상태 패턴을 사용하여 "완료" 버튼을 눌러야만 선택 결과가 Binding에 반영됩니다.
///
/// **사용 예시:**
/// ```swift
/// .navigationDestination(isPresented: $showWorkplaceSelect) {
///     WorkplaceSelectView(
///         workplaces: workplaceList,
///         selectedWorkplace: $form.selectedWorkplace
///     )
/// }
/// ```
struct WorkplaceSelectView: View {
    
    // MARK: - Properties
    
    @Environment(\.dismiss) private var dismiss
    
    private let workplaces: [WorkplaceSummary]
    @Binding private var selectedWorkplace: WorkplaceSummary?
    
    @State private var tempSelectedId: Int?
    
    // MARK: - Initializer
    
    /// 새로운 `WorkplaceSelectView`를 생성합니다.
    ///
    /// - Parameters:
    ///   - workplaces: 선택 가능한 근무지 목록입니다.
    ///   - selectedWorkplace: 부모 뷰와 연결되어 선택 결과를 양방향으로 공유할 바인딩(`@Binding`)입니다.
    init(workplaces: [WorkplaceSummary], selectedWorkplace: Binding<WorkplaceSummary?>) {
        self.workplaces = workplaces
        self._selectedWorkplace = selectedWorkplace
        self._tempSelectedId = State(initialValue: selectedWorkplace.wrappedValue?.id)
    }
    
    // MARK: - UI Components
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("등록할 근무지를 선택해 주세요")
                .font(.headBold(18))
                .foregroundColor(.gray900)
                .padding(.top, 20)
            
            VStack(spacing: 12) {
                ForEach(workplaces, id: \.id) { workplace in
                    CheckButtonView(
                        title: workplace.name,
                        isSelected: binding(for: workplace.id)
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
            BaseNavigationBarSU(title: "근무지 선택", onBackTap: {
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
                    if let id = tempSelectedId,
                       let workplace = workplaces.first(where: { $0.id == id }) {
                        selectedWorkplace = workplace
                    }
                    dismiss()
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(.primaryBackground)
                .disabled(tempSelectedId == nil)
            }
        }
        .background(.primaryBackground)
        .toolbar(.hidden, for: .navigationBar)
    }
}

// MARK: - Private Methods

private extension WorkplaceSelectView {
    /// 단일 선택을 위한 Binding 생성
    ///
    /// `CheckButtonView`는 `Binding<Bool>`을 받으므로,
    /// 각 항목의 id를 `tempSelectedId`와 비교하여 선택 상태를 반환하고,
    /// `true`로 설정되면 해당 id를 `tempSelectedId`에 저장합니다.
    func binding(for id: Int) -> Binding<Bool> {
        Binding<Bool>(
            get: { tempSelectedId == id },
            set: { isSelected in
                if isSelected {
                    tempSelectedId = id
                }
            }
        )
    }
}

// MARK: - Preview

#Preview {
    struct Wrapper: View {
        @State private var selected: WorkplaceSummary?
        
        private let workplaces: [WorkplaceSummary] = [
            WorkplaceSummary(id: 1, name: "맥도날드", isShared: false),
            WorkplaceSummary(id: 2, name: "스타벅스", isShared: true),
            WorkplaceSummary(id: 3, name: "서브웨이", isShared: false),
            WorkplaceSummary(id: 4, name: "서브웨이", isShared: false),
            WorkplaceSummary(id: 5, name: "서브웨이", isShared: false),
            WorkplaceSummary(id: 6, name: "서브웨이", isShared: false),
            WorkplaceSummary(id: 7, name: "서브웨이", isShared: false),
            WorkplaceSummary(id: 8, name: "서브웨이", isShared: false),
            WorkplaceSummary(id: 9, name: "서브웨이", isShared: false),
            WorkplaceSummary(id: 10, name: "서브웨이", isShared: false),
            WorkplaceSummary(id: 11, name: "서브웨이", isShared: false),
        ]
        
        var body: some View {
            NavigationStack {
                WorkplaceSelectView(
                    workplaces: workplaces,
                    selectedWorkplace: $selected
                )
            }
        }
    }
    return Wrapper()
}
