//
//  DraftRoutineStorage.swift
//  MOUP
//
//  Created by 신영 on 10/26/25.
//

import Foundation

final class DraftRoutineStorage: DraftRoutineStorageProtocol {
    static let shared = DraftRoutineStorage()
    
    private let key = "DraftRoutine"
    private let userDefaults = UserDefaults.standard
    
    func saveDraft(_ routine: DraftRoutine) {
        do {
            let encoded = try JSONEncoder().encode(routine)
            userDefaults.set(encoded, forKey: key)
        } catch {
            print("Draft 저장 실패: \(error)")
        }
    }
    
    func loadDraft() -> DraftRoutine? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        
        do {
            return try JSONDecoder().decode(DraftRoutine.self, from: data)
        } catch {
            print("Draft 로드 실패: \(error)")
            return nil
        }
    }
    
    func deleteDraft() {
        userDefaults.removeObject(forKey: key)
    }
}
