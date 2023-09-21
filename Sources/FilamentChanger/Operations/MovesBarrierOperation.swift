//
//  MovesBarrierOperation.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

struct MovesBarrierOperation: Operation {
    typealias Error = Never
    
    func perform(in context: Context, filamentChanger: FilamentChanger) throws {
        context.toolhead.waitForMovesToFinish()
    }
}
