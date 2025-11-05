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
            print("✅ [DraftStorage] Draft 저장 완료")
        } catch {
            print("❌ [DraftStorage] Draft 저장 실패: \(error)")
        }
    }

    func loadDraft() -> DraftRoutine? {
        guard let data = userDefaults.data(forKey: key) else {
            print("ℹ️ [DraftStorage] 저장된 Draft 없음")
            return nil
        }

        do {
            let draft = try JSONDecoder().decode(DraftRoutine.self, from: data)
            print("✅ [DraftStorage] Draft 로드 완료")
            return draft
        } catch {
            print("❌ [DraftStorage] Draft 로드 실패: \(error)")
            return nil
        }
    }

    func deleteDraft() {
        let hadDraft = userDefaults.data(forKey: key) != nil
        userDefaults.removeObject(forKey: key)

        if hadDraft {
            print("✅ [DraftStorage] Draft 삭제 완료")
        }
    }
}
