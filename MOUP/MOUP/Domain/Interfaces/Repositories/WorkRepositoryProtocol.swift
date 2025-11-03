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
    
    /// 단일 근무 업데이트 API를 호출합니다.
    /// - Parameters:
    ///   - workId: 수정할 근무의 ID
    ///   - requestDTO: 근무 수정 정보
    func updateMySingleWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws
    /// 반복 근무 전체 업데이트 API를 호출합니다.
    /// - Parameters:
    ///   - workId: 수정할 반복 근무 시리즈의 기준 ID
    ///   - requestDTO: 근무 수정 정보
    /// - Returns: 이 작업으로 인해 업데이트된 **모든** 반복 근무 건의 ID 목록 (`[Int]`)
    func updateMyRecurringWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws -> [Int]
    /// 단일 근무 업데이트 API를 호출합니다. (사장님 전용)
    /// - Parameters:
    ///   - workplaceId: 매장 ID
    ///   - workerId: 근무자 ID
    ///   - workId: 수정할 근무의 ID
    ///   - requestDTO: 근무 수정 정보
    func updateWorkerSingleWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws
    /// 반복 근무 전체 업데이트 API를 호출합니다. (사장님 전용)
    /// - Parameters:
    ///   - workplaceId: 매장 ID
    ///   - workerId: 근무자 ID
    ///   - workId: 수정할 반복 근무 시리즈의 기준 ID
    ///   - requestDTO: 근무 수정 정보
    /// - Returns: 이 작업으로 인해 업데이트된 **모든** 반복 근무 건의 ID 목록 (`[Int]`)
    func updateWorkerRecurringWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws -> [Int]
    
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
