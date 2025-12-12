//
//  WorkRegisterCoordinatorProtocol.swift
//  MOUP
//
//  Created by 양원식 on 8/8/25.
//

protocol WorkRegisterCoordinatorProtocol: Coordinator {
    func showSelectColorLabel()
    func showSelectWorkplace()
    func showRepeatSetting()
    func showRoutineSelection()
    func showWorkerSelection(workplaceId: Int)
}
