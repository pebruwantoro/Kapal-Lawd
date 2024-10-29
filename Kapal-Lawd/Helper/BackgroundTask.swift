//
//  BackgroundTask.swift
//  Kapal-Lawd
//
//  Created by Doni Pebruwantoro on 29/10/24.
//
import Foundation
import BackgroundTasks

class BackgroundTaskManager: ObservableObject {
    private let resetTaskID = "com.Kapal-Lawd.reset"

    init() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: resetTaskID, using: nil) { task in
            self.handleResetTask(task: task as! BGAppRefreshTask)
        }
    }

    func scheduleResetTask() {
        let request = BGAppRefreshTaskRequest(identifier: resetTaskID)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 0.25 * 60) // Example: 15 min delay

        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Failed to schedule reset task: \(error)")
        }
    }

    private func handleResetTask(task: BGAppRefreshTask) {
        scheduleResetTask()
        task.setTaskCompleted(success: true)
    }
}
