//
//  WorkRepositoryProtocol.swift
//  MOUP
//
//  Created by 서동환 on 10/30/25.
//

protocol WorkRepositoryProtocol: AnyObject {
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
