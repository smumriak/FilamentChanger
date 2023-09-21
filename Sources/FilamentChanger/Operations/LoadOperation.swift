//
//  LoadOperation.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

struct LoadOperation: Operation {
    let speed: Float
    let acceleration: Float
    let position: FilamentChanger.Position
    let motor: Motor

    func perform(in context: Context, filamentChanger: FilamentChanger) throws {
        let feeder = context.feeder
        let toolhead = context.toolhead

        var moveDelta: Float = 0.0
        var distance = filamentChanger.distance(to: position)
        var toolheadPosition = context.toolhead.position

        repeat {
            toolheadPosition.e += distance

            if motor.contains(.feeder) {
                if motor.contains(.extruder) {
                    feeder.synchronize()
                } else {
                    feeder.position = 0.0
                    feeder.move(to: distance, speed: speed, acceleration: acceleration)
                }
            }

            if motor.contains(.extruder) {
                toolhead.manualMove(to: toolheadPosition, speed: speed)
                toolhead.dwell(for: .milliseconds(50))
            }

            toolhead.waitForMovesToFinish()

            let actualMovedDistance = context.encoder.distance
            moveDelta = distance - actualMovedDistance
            context.encoder.distance = 0.0
            distance = moveDelta
        } while moveDelta > 0.0

        if motor.contains(.extruder) {
            toolhead.position = toolheadPosition
        }

        if motor.contains([.extruder, .feeder]) {
            feeder.resetSynchronization()
        }
    }
}
