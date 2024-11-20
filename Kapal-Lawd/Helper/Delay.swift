//
//  Delay.swift
//  Kapal-Lawd
//
//  Created by Doni Pebruwantoro on 29/10/24.
//

import Foundation

func delay(_ seconds: Double, completion: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
        completion()
    }
}

func throttle(interval: TimeInterval, action: @escaping () -> Void) -> () -> Void {
    var lastExecutionDate: Date = .distantPast
    var workItem: DispatchWorkItem?

    return {
        workItem?.cancel()
        
        let delay = max(interval - Date().timeIntervalSince(lastExecutionDate), 0)
        workItem = DispatchWorkItem {
            lastExecutionDate = Date()
            action()
        }
        
        if let workItem = workItem {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: workItem)
        }
    }
}
