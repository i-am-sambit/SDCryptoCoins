//
//  CustomDispatchGroup.swift
//  CryptoCoins
//
//  Created by Sambit Prakash Dash on 28/10/24.
//

import Foundation

protocol TaskManagerable {
    var pendingTasks: Int { get }
    
    func enter()
    func leave(completionHandler: @escaping () -> Void)
}

protocol CompletionHandlerable {
    func notify(queue: DispatchQueue, execute: @escaping (() -> Void))
    func handleCompletion()
}

protocol WaitTimeManagable {
    func wait(for task: TaskManagerable)
    func wait(timeout: DispatchTime, for task: TaskManagerable) -> DispatchTimeoutResult
}

class TaskManager: TaskManagerable {
    var pendingTasks: Int = 0
    
    func enter() {
        pendingTasks += 1
    }
    
    func leave(completionHandler: @escaping () -> Void) {
        guard pendingTasks > 0 else { return }
        pendingTasks -= 1
        if pendingTasks == 0 {
            completionHandler()
        }
    }
}

class CompletionHandlerManager: CompletionHandlerable {
    var completionHandler: () -> Void = {}
    
    func notify(queue: DispatchQueue, execute: @escaping (() -> Void)) {
        self.completionHandler = execute
    }
    
    func handleCompletion() {
        completionHandler()
    }
}

class WaitManager: WaitTimeManagable {
    func wait(for task: any TaskManagerable) {
        while task.pendingTasks > 0 {
            Thread.sleep(forTimeInterval: 0.1)
        }
    }
    
    func wait(timeout: DispatchTime, for task: any TaskManagerable) -> DispatchTimeoutResult {
        var result: DispatchTimeoutResult = .success
        let semaphore = DispatchSemaphore(value: 0)
        
        while task.pendingTasks > 0 {
            let remainingTime = timeout.uptimeNanoseconds - DispatchTime.now().uptimeNanoseconds
            
            if remainingTime <= 0 {
                result = .timedOut
                break
            }
            
            let waitTime = DispatchTime.now() + DispatchTimeInterval.nanoseconds(Int(remainingTime))
            
            DispatchQueue.global().async {
                if task.pendingTasks == 0 {
                    semaphore.signal()
                }
            }
            
            let waitResult = semaphore.wait(timeout: waitTime)
            if waitResult == .timedOut {
                result = .timedOut
                break
            }
        }
        return result
    }
    
    
}

class CustomDispatchGroup {
    private var task: TaskManagerable
    private var completionHandler: CompletionHandlerable
    private var waitTime: WaitTimeManagable
    
    init(task: TaskManagerable, completionHandler: CompletionHandlerable, waitTime: WaitTimeManagable) {
        self.task = task
        self.completionHandler = completionHandler
        self.waitTime = waitTime
    }
    
    convenience init() {
        self.init(
            task: TaskManager(),
            completionHandler: CompletionHandlerManager(),
            waitTime: WaitManager()
        )
    }
    
    func enter() {
        task.enter()
    }
    
    func leave() {
        task.leave(completionHandler: completionHandler.handleCompletion)
    }
    
    func notify(queue: DispatchQueue, execute: @escaping (() -> Void)) {
        completionHandler.notify(queue: queue, execute: execute)
    }
    
    func wait() {
        waitTime.wait(for: task)
    }
    
    func wait(timeout: DispatchTime) -> DispatchTimeoutResult {
        waitTime.wait(timeout: timeout, for: task)
    }
}
