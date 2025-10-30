//
//  WorkRepositoryProtocol.swift
//  MOUP
//
//  Created by 서동환 on 10/30/25.
//

protocol WorkRepositoryProtocol: AnyObject {
    
    /// 사용자 근무 생성 API를 호출합니다.
    func createMyWork(workplaceId: Int, requestDTO: MyWorkCreateRequestDTO) async throws -> WorkCreateResponseDTO
    /// 근무자 근무 생성 API를 호출합니다. (사장님 전용)
    func createWorkerWork(workplaceId: Int, workerId: Int, requestDTO: WorkerWorkCreateRequestDTO) async throws -> WorkCreateResponseDTO
    
    /// 근무 상세 조회 API를 호출합니다.
    func fetchWorkDetail(workId: Int) async throws -> WorkDetailResponseDTO
    /// 근무 요약 조회 API를 호출합니다.
    func fetchWorkSummary(workId: Int) async throws -> WorkSummaryResponseDTO
    /// 사용자의 모든 근무 목록 조회 API를 호출합니다.
    func fetchAllMyWorkList(baseYearMonth: String) async throws -> WorkCalendarListResponseDTO
    /// 특정 근무지의 내 근무 목록 조회 API를 호출합니다.
    func fetchWorkplaceMyWorkList(workplaceId: Int, baseYearMonth: String) async throws -> WorkCalendarListResponseDTO
    /// 특정 근무지의 모든 근무 목록 조회 API를 호출합니다.
    func fetchWorkplaceAllWorkList(workplaceId: Int, baseYearMonth: String) async throws -> WorkCalendarListResponseDTO
    
    /// 사용자 근무 업데이트 API를 호출합니다.
    /// - Returns: 반복 근무가 업데이트되어 데이터가 반환(200 OK)되면 `WorkCreateResponseDTO`,
    ///            단일 근무만 업데이트되어 데이터가 없는 성공(204 No Content) 시 `nil`을 반환합니다.
    func updateMyWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws -> WorkCreateResponseDTO?
    /// 근무자 근무 업데이트 API를 호출합니다. (사장님 전용)
    /// - Returns: 반복 근무가 업데이트되어 데이터가 반환(200 OK)되면 `WorkCreateResponseDTO`,
    ///            단일 근무만 업데이트되어 데이터가 없는 성공(204 No Content) 시 `nil`을 반환합니다.
    func updateWorkerWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws -> WorkCreateResponseDTO?
    
    /// 단일 근무 삭제 API를 호출합니다.
    func deleteWork(workId: Int) async throws
    /// 반복 근무 전체 삭제 API를 호출합니다.
    func deleteRecurringWork(workId: Int) async throws
    
    /// 출근 API를 호출합니다.
    /// - Returns: 신규 근무가 생성되어 데이터가 반환(201 Created) 시 `WorkCreateResponseDTO`,
    ///            기존 근무에 실제 출근 시간을 업데이트(204 No Content)하여 데이터가 없는 성공 시 `nil`을 반환합니다.
    func startWork(workplaceId: Int) async throws -> WorkCreateResponseDTO?
    /// 퇴근 API를 호출합니다.
    func endWork(workplaceId: Int) async throws
}
