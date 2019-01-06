//
//  WorkQueue.swift
//  mesher iOS
//
//  Created by Eric O'Connell on 1/5/19.
//  Copyright © 2019 Eric O'Connell. All rights reserved.
//

import Foundation

typealias JobId = String
typealias Work = () throws -> Void

enum Status {
    case added, started, completed, errored
}


struct Job {
    let id: JobId
    var status: Status
    let work: Work
}

class WorkManager {
    var jobs = [JobId: Job]()

    let workQueue = DispatchQueue.global(qos: .userInitiated)
    let dataQueue = DispatchQueue(label: "net.compassing.mesher.WorkManager", attributes: .concurrent)
    let dispatchGroup = DispatchGroup()

    func add(id: JobId, work: @escaping Work) {
        let job = Job(id: id, status: .added, work: work)
        
        dispatchGroup.enter()
        logger("About to add \(id) on \(DispatchQueue.currentLabel)")
        dataQueue.async(flags: .barrier) {
            logger("Adding \(id) on \(DispatchQueue.currentLabel)")
            self.jobs[job.id] = job
            self.start(job)
        }
    }
    
    func wait() {
        dispatchGroup.wait()
    }
    
    func notify(queue: DispatchQueue, work: DispatchWorkItem) {
        dispatchGroup.notify(
            queue: queue,
            work: work
        )
    }
    
    private func start(_ job: Job) {
        workQueue.async {
            logger("Starting \(job.id)")
            self.set(job, status: .started)
            
            do {
                try job.work()
                self.set(job, status: .completed)
            } catch {
                logger("Error while running job: \(job.id): \(error)")
                self.set(job, status: .errored)
            }

            self.dispatchGroup.leave()
        }
    }
    
    private func set(_ job: Job, status: Status) {
        logger("About to set \(DispatchQueue.currentLabel)")
        self.dataQueue.async(flags: .barrier) {
            logger("Setting job \(job.id) to \(status) on \(DispatchQueue.currentLabel)")
            self.jobs[job.id]!.status = status
        }
    }
}
