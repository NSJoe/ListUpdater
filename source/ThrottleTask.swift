//
//  ThrottleTask.swift
//  ListUpdater
//
//  Created by Joe's MacBook Pro on 2017/7/9.
//  Copyright © 2017年 joe. All rights reserved.
//

import Foundation

class ThrottleTask {
    
    typealias Task = (Void) -> Void
    
    private var throttle:Float = 0.0
    private var tasks = [Task]()
    private let queue = DispatchQueue(label: "throttle.task.serial.queue", attributes: .init(rawValue:0))
    
    init(throttle:Float) {
        self.throttle = throttle
    }
    
    func add(task:@escaping Task) -> Void {
        objc_sync_enter(self)
        self.tasks.append(task)
        if self.tasks.count == 1 {
            self.execute()
        }
        objc_sync_exit(self)
    }
    
    func execute() -> Void {
        queue.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(Int(self.throttle * 1000.0))) {
            objc_sync_enter(self)
            guard let task = self.tasks.last else { return }
            self.tasks.removeAll()
            objc_sync_exit(self)
            task()
        }
    }
    
}
