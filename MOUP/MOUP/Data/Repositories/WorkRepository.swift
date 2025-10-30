//
//  WorkRepository.swift
//  MOUP
//
//  Created by 서동환 on 10/30/25.
//

final class WorkRepository: WorkRepositoryProtocol {
    private let workService: WorkServiceProtocol
    
    init(workService: WorkServiceProtocol) { self.workService = workService }
    
    func createMyWork(workplaceId: Int, requestDTO: MyWorkCreateRequestDTO) async throws -> [Int] {
        try await workService.createMyWork(workplaceId: workplaceId, requestDTO: requestDTO).workIdList
    }
    
    func createWorkerWork(workplaceId: Int, workerId: Int, requestDTO: WorkerWorkCreateRequestDTO) async throws -> [Int] {
        try await workService.createWorkerWork(workplaceId: workplaceId, workerId: workerId, requestDTO: requestDTO).workIdList
    }
    
    func fetchWorkDetail(workId: Int) async throws -> WorkData {
        try await workService.fetchWorkDetail(workId: workId).toDomain()
    }
    
    func fetchWorkSummary(workId: Int) async throws -> WorkSummary {
        try await workService.fetchWorkSummary(workId: workId).toDomain()
    }
    
    func fetchAllMyWorkList(baseYearMonth: String) async throws -> [WorkSummary] {
        try await workService.fetchAllMyWorkList(baseYearMonth: baseYearMonth).workSummaryInfoList.map { $0.toDomain() }
    }
    
    func fetchWorkplaceMyWorkList(workplaceId: Int, baseYearMonth: String) async throws -> [WorkSummary] {
        try await workService.fetchWorkplaceMyWorkList(workplaceId: workplaceId, baseYearMonth: baseYearMonth).workSummaryInfoList.map { $0.toDomain() }
    }
    
    func fetchWorkplaceAllWorkList(workplaceId: Int, baseYearMonth: String) async throws -> [WorkSummary] {
        try await workService.fetchWorkplaceAllWorkList(workplaceId: workplaceId, baseYearMonth: baseYearMonth).workSummaryInfoList.map { $0.toDomain() }
    }
    
    func updateMyWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws -> [Int]? {
        try await workService.updateMyWork(workId: workId, requestDTO: requestDTO)?.workIdList
    }
    
    func updateWorkerWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws -> [Int]? {
        try await workService.updateWorkerWork(workplaceId: workplaceId, workerId: workerId, workId: workId, requestDTO: requestDTO)?.workIdList
    }
    
    func deleteWork(workId: Int) async throws {
        try await workService.deleteWork(workId: workId)
    }
    
    func deleteRecurringWork(workId: Int) async throws {
        try await workService.deleteRecurringWork(workId: workId)
    }
    
    func startWork(workplaceId: Int) async throws -> [Int]? {
        try await workService.startWork(workplaceId: workplaceId)?.workIdList
    }
    
    func endWork(workplaceId: Int) async throws {
        try await workService.endWork(workplaceId: workplaceId)
    }
}
