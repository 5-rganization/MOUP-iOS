//
//  WorkRepositoryProtocol.swift
//  MOUP
//
//  Created by 서동환 on 10/30/25.
//

protocol WorkRepositoryProtocol: AnyObject {
    
    /// 사용자 근무 생성 API를 호출합니다.
    /// - Returns: 생성된 근무의 ID 배열 `[Int]`
    func createMyWork(workplaceId: Int, requestDTO: MyWorkCreateRequestDTO) async throws -> [Int]
    /// 근무자 근무 생성 API를 호출합니다. (사장님 전용)
    /// - Returns: 생성에 실패한 근무자들의 정보 배열 `[FailedWorkerInfo]`
    ///   - 생성에 모두 성공했다면 빈 배열
    func createWorkersWork(workplaceId: Int, requestDTO: WorkersWorkCreateRequestDTO) async throws -> [FailedWorkerInfo]
    
    /// 근무 상세 조회 API를 호출합니다.
    func fetchWorkDetail(workId: Int) async throws -> WorkData
    /// 근무 요약 조회 API를 호출합니다.
    func fetchWorkSummary(workId: Int) async throws -> WorkSummary
    /// 사용자의 모든 근무 목록 조회 API를 호출합니다.
    func fetchAllMyWorkList(baseYearMonth: String) async throws -> [WorkSummary]
    /// 특정 근무지의 내 근무 목록 조회 API를 호출합니다.
    func fetchWorkplaceMyWorkList(workplaceId: Int, baseYearMonth: String) async throws -> [WorkSummary]
    /// 특정 근무지의 모든 근무 목록 조회 API를 호출합니다.
    func fetchWorkplaceAllWorkList(workplaceId: Int, baseYearMonth: String) async throws -> [WorkSummary]
    
    /// 사용자 근무 업데이트 API를 호출합니다.
    /// - Returns: 반복 근무가 수정되어 ID 목록이 반환되면 `[Int]`,
    ///            단일 근무만 수정되어 데이터가 없는 성공 시 `nil`
    func updateMyWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws -> [Int]?
    /// 근무자 근무 업데이트 API를 호출합니다. (사장님 전용)
    /// - Returns: 반복 근무가 수정되어 ID 목록이 반환되면 `[Int]`,
    ///            단일 근무만 수정되어 데이터가 없는 성공 시 `nil`
    func updateWorkerWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws -> [Int]?
    
    /// 단일 근무 삭제 API를 호출합니다.
    func deleteWork(workId: Int) async throws
    /// 반복 근무 전체 삭제 API를 호출합니다.
    func deleteRecurringWork(workId: Int) async throws
    
    /// 출근 API를 호출합니다.
    /// - Returns: 신규 근무 생성(201) 시 생성된 근무의 ID 배열(단일 항목) `[Int]`,
    ///            기존 근무 업데이트(204) 시 `nil`
    func startWork(workplaceId: Int) async throws -> [Int]?
    /// 퇴근 API를 호출합니다.
    func endWork(workplaceId: Int) async throws
}
