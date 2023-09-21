//
//  FeederBuzzOperation.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

struct FeederBuzzOperation: Operation {
    let count: UInt
    let speed: Float
    let distance: Float
    let motor: Motor

    func perform(in context: Context, filamentChanger: FilamentChanger) throws {
        let toolhead = context.toolhead
        let feeder = context.feeder

        for _ in 0..<count {
            toolhead.dwell(for: .milliseconds(50))
            feeder.move(to: 0.5, speed: 25, acceleration: feederAcceleration)
            toolhead.dwell(for: .milliseconds(50))
            feeder.move(to: -0.5, speed: 25, acceleration: feederAcceleration)
        }

        toolhead.dwell(for: .milliseconds(200))
    }
}
