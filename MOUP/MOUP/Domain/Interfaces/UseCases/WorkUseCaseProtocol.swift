//
//  WorkUseCaseProtocol.swift
//  MOUP
//
//  Created by 서동환 on 10/30/25.
//

/// 근무 관련 Use Case Protocol
protocol WorkUseCaseProtocol: AnyObject {
    
    /// 근무지(매장)에 내 근무를 생성합니다.
    /// - Returns: 생성된 근무의 ID 배열 `[Int]`
    func createMyWork(workplaceId: Int, requestDTO: MyWorkCreateRequestDTO) async throws -> [Int]
    /// 근무자에게 근무를 생성합니다. (사장님 전용)
    /// - Returns: 생성에 실패한 근무자들의 정보 배열 `[FailedWorkerInfo]`
    ///   - 생성에 모두 성공했다면 빈 배열
    func createWorkersWork(workplaceId: Int, requestDTO: WorkersWorkCreateRequestDTO) async throws -> [FailedWorkerInfo]
    
    /// 내 근무의 상세 정보를 조회합니다.
    func fetchMyWorkDetail(workId: Int) async throws -> MyWorkData
    /// 근무자 근무의 상세 정보를 조회합니다. (사장님 전용)
    func fetchWorkerWorkDetail(workId: Int) async throws -> WorkerWorkData
    /// 근무의 요약 정보를 조회합니다.
    func fetchWorkSummary(workId: Int) async throws -> WorkSummary
    
    /// 내 모든 근무 목록을 캘린더 형식으로 조회합니다.
    /// - Parameter baseYearMonth: 조회 기준 월 (`yyyy-MM` 형식)
    func fetchAllMyWorkList(baseYearMonth: String) async throws -> [WorkSummary]
    
    /// 특정 근무지(매장)에서 내 근무 목록을 캘린더 형식으로 조회합니다.
    /// - Parameter baseYearMonth: 조회 기준 월 (`yyyy-MM` 형식)
    func fetchWorkplaceMyWorkList(workplaceId: Int, baseYearMonth: String) async throws -> [WorkSummary]
    
    /// 특정 근무지(매장)의 모든 근무 목록을 캘린더 형식으로 조회합니다.
    /// - Parameter baseYearMonth: 조회 기준 월 (`yyyy-MM` 형식)
    func fetchWorkplaceAllWorkList(workplaceId: Int, baseYearMonth: String) async throws -> [WorkSummary]
    
    /// 단일 근무를 업데이트합니다.
    /// - Parameters:
    ///   - workId: 수정할 근무의 ID
    ///   - requestDTO: 근무 수정 정보
    func updateMySingleWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws
    /// 반복 근무 전체를 업데이트합니다.
    /// - Parameters:
    ///   - workId: 수정할 반복 근무 시리즈의 기준 ID
    ///   - requestDTO: 근무 수정 정보
    /// - Returns: 이 작업으로 인해 업데이트된 **모든** 반복 근무 건의 ID 목록 (`[Int]`)
    func updateMyRecurringWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws -> [Int]
    
    /// 근무자의 단일 근무를 업데이트합니다. (사장님 전용)
    /// - Parameters:
    ///   - workplaceId: 매장 ID
    ///   - workerId: 근무자 ID
    ///   - workId: 수정할 근무의 ID
    ///   - requestDTO: 근무 수정 정보
    func updateWorkerSingleWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws
    /// 근무자의 반복 근무 전체를 업데이트합니다. (사장님 전용)
    /// - Parameters:
    ///   - workplaceId: 매장 ID
    ///   - workerId: 근무자 ID
    ///   - workId: 수정할 반복 근무 시리즈의 기준 ID
    ///   - requestDTO: 근무 수정 정보
    /// - Returns: 이 작업으로 인해 업데이트된 **모든** 반복 근무 건의 ID 목록 (`[Int]`)
    func updateWorkerRecurringWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws -> [Int]
    
    /// 단일 근무를 삭제합니다.
    func deleteWork(workId: Int) async throws
    /// 해당 근무가 포함된 모든 반복 근무를 삭제합니다.
    func deleteRecurringWork(workId: Int) async throws
    
    /// 근무를 시작(출근)합니다. (알바생 전용)
    /// - Returns: 신규 근무 생성(201) 시 생성된 근무의 ID 배열(단일 항목) `[Int]`,
    ///            기존 근무 업데이트(204) 시 `nil`
    func startWork(workplaceId: Int) async throws -> [Int]?
    
    /// 근무를 종료(퇴근)합니다. (알바생 전용)
    func endWork(workplaceId: Int) async throws
}
