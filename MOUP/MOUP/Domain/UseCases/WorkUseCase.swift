//
//  WorkUseCase.swift
//  MOUP
//
//  Created by 서동환 on 10/30/25.
//

final class WorkUseCase: WorkUseCaseProtocol {
    private let workRepository: WorkRepositoryProtocol
    
    init(workRepository: WorkRepositoryProtocol) { self.workRepository = workRepository }
    
    func createMyWork(workplaceId: Int, requestDTO: MyWorkCreateRequestDTO) async throws -> [Int] {
        try await workRepository.createMyWork(workplaceId: workplaceId, requestDTO: requestDTO)
    }
    
    func createWorkersWork(workplaceId: Int, requestDTO: WorkersWorkCreateRequestDTO) async throws -> [FailedWorkerInfo] {
        try await workRepository.createWorkersWork(workplaceId: workplaceId, requestDTO: requestDTO)
    }
    
    func fetchMyWorkDetail(workId: Int) async throws -> MyWorkData {
        try await workRepository.fetchWorkDetail(workId: workId).toMyWorkData()
    }
    
    func fetchWorkerWorkDetail(workId: Int) async throws -> WorkerWorkData {
        try await workRepository.fetchWorkDetail(workId: workId).toWorkerWorkData()
    }
    
    func fetchWorkSummary(workId: Int) async throws -> WorkSummary {
        try await workRepository.fetchWorkSummary(workId: workId)
    }
    
    func fetchAllMyWorkList(baseYearMonth: String) async throws -> [WorkSummary] {
        try await workRepository.fetchAllMyWorkList(baseYearMonth: baseYearMonth)
    }
    
    func fetchWorkplaceMyWorkList(workplaceId: Int, baseYearMonth: String) async throws -> [WorkSummary] {
        try await workRepository.fetchWorkplaceMyWorkList(workplaceId: workplaceId, baseYearMonth: baseYearMonth)
    }
    
    func fetchWorkplaceAllWorkList(workplaceId: Int, baseYearMonth: String) async throws -> [WorkSummary] {
        try await workRepository.fetchWorkplaceAllWorkList(workplaceId: workplaceId, baseYearMonth: baseYearMonth)
    }
    
    func updateMySingleWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws {
        try await workRepository.updateMySingleWork(workId: workId, requestDTO: requestDTO)
    }
    
    func updateMyRecurringWork(workId: Int, requestDTO: MyWorkUpdateRequestDTO) async throws -> [Int] {
        try await workRepository.updateMyRecurringWork(workId: workId, requestDTO: requestDTO)
    }
    
    func updateWorkerSingleWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws  {
        try await workRepository.updateWorkerSingleWork(workplaceId: workplaceId, workerId: workerId, workId: workId, requestDTO: requestDTO)
    }
    
    func updateWorkerRecurringWork(workplaceId: Int, workerId: Int, workId: Int, requestDTO: WorkerWorkUpdateRequestDTO) async throws -> [Int] {
        try await workRepository.updateWorkerRecurringWork(workplaceId: workplaceId, workerId: workerId, workId: workId, requestDTO: requestDTO)
    }
    
    func deleteWork(workId: Int) async throws {
        try await workRepository.deleteWork(workId: workId)
    }
    
    func deleteRecurringWork(workId: Int) async throws {
        try await workRepository.deleteRecurringWork(workId: workId)
    }
    
    func startWork(workplaceId: Int) async throws -> [Int]? {
        try await workRepository.startWork(workplaceId: workplaceId)
    }
    
    func endWork(workplaceId: Int) async throws {
        try await workRepository.endWork(workplaceId: workplaceId)
    }
}
