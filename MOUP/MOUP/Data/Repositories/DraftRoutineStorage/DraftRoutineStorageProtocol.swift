//
//  DraftRoutineStorageProtocol.swift
//  MOUP
//
//  Created by 신영 on 10/26/25.
//

import Foundation

protocol DraftRoutineStorageProtocol {
    func saveDraft(_ routine: DraftRoutine)
    func loadDraft() -> DraftRoutine?
    func deleteDraft()
}
