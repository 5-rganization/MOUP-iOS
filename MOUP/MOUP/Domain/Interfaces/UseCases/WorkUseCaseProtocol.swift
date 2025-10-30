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
    /// - Returns: 생성된 근무의 ID 배열 `[Int]`
    func createWorkerWork(workplaceId: Int, workerId: Int, requestDTO: WorkerWorkCreateRequestDTO) async throws -> [Int]
    
    /// 근무의 상세 정보를 조회합니다.
    func fetchWorkDetail(workId: Int) async throws -> WorkData
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
    
    /// 내 근무를 업데이트합니다.
    /// - Returns: 반복 근무가 수정되어 ID 목록이 반환되면 `[Int]`,
    ///            단일 근무만 수정되어 데이터가 없는 성공 시 `nil`
    func updateMyWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws -> [Int]?
    
    /// 근무자의 근무를 업데이트합니다. (사장님 전용)
    /// - Returns: 반복 근무가 수정되어 ID 목록이 반환되면 `[Int]`,
    ///            단일 근무만 수정되어 데이터가 없는 성공 시 `nil`
    func updateWorkerWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws -> [Int]?
    
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
