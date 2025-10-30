//
//  WorkUseCaseProtocol.swift
//  MOUP
//
//  Created by 서동환 on 10/30/25.
//

/// 근무 관련 Use Case Protocol
/// - `createMyWork`: 근무지(매장)에 사용자 근무 생성
/// - `createWorkerWork`: 근무자에게 근무 생성 (사장님 전용)
/// - `fetchWork`: 근무 조회
/// - `fetchAllMyWorkList`: 사용자의 모든 근무 범위 조회
/// - `fetchWorkplaceMyWorkList`: 특정 근무지(매장)에서 사용자 근무 범위 조회
///   - `baseYearMonth` 형식: `yyyy-MM`
/// - `fetchWorkplaceAllWorkList`: 특정 근무지(매장)의 모든 근무 범위 조회
///   - `baseYearMonth` 형식: `yyyy-MM`
/// - `updateMyWork`: 사용자 근무 업데이트
/// - `updateWorkerWork`: 근무자 근무 업데이트 (사장님 전용)
/// - `deleteWork`: 근무 삭제
/// - `deleteRecurringWork`: 반복 근무 삭제
/// - `startWork`: 근무 출근 (알바생 전용)
/// - `endWork`: 근무 퇴근 (알바생 전용)
protocol WorkUseCaseProtocol: AnyObject {
    func createMyWork(workplaceId: Int, requestDTO: MyWorkCreateRequestDTO) async throws -> WorkCreateResponseDTO
    func createWorkerWork(workplaceId: Int, workerId: Int, requestDTO: WorkerWorkCreateRequestDTO) async throws -> WorkCreateResponseDTO
    
    func fetchWorkDetail(workId: Int) async throws -> WorkDetailResponseDTO
    func fetchWorkSummary(workId: Int) async throws -> WorkSummaryResponseDTO
    func fetchAllMyWorkList(baseYearMonth: String) async throws -> WorkCalendarListResponseDTO
    func fetchWorkplaceMyWorkList(workplaceId: Int, baseYearMonth: String) async throws -> WorkCalendarListResponseDTO
    func fetchWorkplaceAllWorkList(workplaceId: Int, baseYearMonth: String) async throws -> WorkCalendarListResponseDTO
    
    func updateMyWork(workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws
    func updateWorkerWork(workplaceId: Int, workerId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws
    
    func deleteWork(workId: Int) async throws
    func deleteRecurringWork(workId: Int) async throws
    
    func startWork(workplaceId: Int) async throws -> WorkCreateResponseDTO?
    func endWork(workplaceId: Int) async throws
}
