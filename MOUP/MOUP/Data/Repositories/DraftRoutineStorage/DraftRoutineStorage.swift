//
//  DraftRoutineStorage.swift
//  MOUP
//
//  Created by 신영 on 10/26/25.
//

import Foundation
import os

final class DraftRoutineStorage: DraftRoutineStorageProtocol {
    static let shared = DraftRoutineStorage()
    
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier!,
        category: "DraftRoutineStorage"
    )
    private let key = "DraftRoutine"
    private let userDefaults = UserDefaults.standard
    
    func saveDraft(_ routine: DraftRoutine) {
        do {
            let encoded = try JSONEncoder().encode(routine)
            userDefaults.set(encoded, forKey: key)
            logger.info("Draft 저장 완료")
        } catch {
            logger.error("Draft 저장 실패: \(error.localizedDescription)")
        }
    }

    func loadDraft() -> DraftRoutine? {
        guard let data = userDefaults.data(forKey: key) else {
            logger.debug("저장된 Draft 없음")
            return nil
        }

        do {
            let draft = try JSONDecoder().decode(DraftRoutine.self, from: data)
            logger.info("Draft 로드 완료")
            return draft
        } catch {
            logger.error("Draft 로드 실패: \(error.localizedDescription)")
            return nil
        }
    }

    func deleteDraft() {
        let hadDraft = userDefaults.data(forKey: key) != nil
        userDefaults.removeObject(forKey: key)

        if hadDraft {
            logger.info("Draft 삭제 완료")
        }
    }
}
