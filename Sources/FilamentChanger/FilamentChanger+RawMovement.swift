//
//  FilamentChanger+RawMovement.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 20.09.2023
//

extension FilamentChanger {
    @discardableResult
    func unloadFilamentFromHotentRaw() -> Float {
        let toolhead = context.toolhead
        let encoder = context.encoder

        encoder.resetPulseCount()
        defer {
            encoder.resetPulseCount()
        }

        toolhead.extrude(distance: softenTheTipDistance, speed: settings.speeds.preciseFilamentMove)
        toolhead.extrude(distance: -(settings.distances[.hotend] - settings.distances[.coolingTube]), speed: settings.speeds.extruderYank)
        toolhead.waitForMovesToFinish()
        toolhead.dwell(for: .seconds(5))

        return encoder.distance
    }

    @discardableResult
    func unloadFilamentFromSensorAfterExtruderRaw() throws -> Float {
        guard let sensorAfterExtruder = context.sensorAfterExtruder else {
            return 0.0
        }

        let toolhead = context.toolhead
        let encoder = context.encoder

        encoder.resetPulseCount()
        defer {
            encoder.resetPulseCount()
        }

        for _ in 0..<8 {
            toolhead.extrude(distance: -babyStep, speed: settings.speeds.preciseFilamentMove)
            toolhead.waitForMovesToFinish()

            if sensorAfterExtruder.isFilamentPresent == false {
                break
            }
        }

        if sensorAfterExtruder.isFilamentPresent == true {
            throw UnloadingError.failedToUnloadFromPosition(.sensorAfterExtruder)
        }

        return encoder.distance
    }

    @discardableResult
    func unloadFilamentFromExtruderRaw() throws -> Float {
        let toolhead = context.toolhead
        let encoder = context.encoder

        defer {
            encoder.resetPulseCount()
        }

        for _ in 0..<8 {
            encoder.resetPulseCount()
            toolhead.extrude(distance: -20.0, speed: settings.speeds.preciseFilamentMove)
            toolhead.waitForMovesToFinish()

            if encoder.distance == 0.0 {
                break
            }
        }

        if let sensorAfterExtruder = context.sensorAfterExtruder, sensorAfterExtruder.isFilamentPresent == true {
            throw UnloadingError.failedToUnloadFromPosition(.inExtruder)
        }

        let distanceMoved = encoder.distance

        if distanceMoved != 0.0 {
            throw UnloadingError.failedToUnloadFromPosition(.inExtruder)
        }

        return distanceMoved
    }

    @discardableResult
    func unloadFilamentFromSensorBeforeExtruderRaw() throws -> Float {
        guard let sensorBeforeExtruder = context.sensorBeforeExtruder else {
            return 0.0
        }

        let toolhead = context.toolhead
        let encoder = context.encoder
        
        encoder.resetPulseCount()
        defer {
            encoder.resetPulseCount()
        }

        for _ in 0..<8 {
            toolhead.extrude(distance: -babyStep, speed: settings.speeds.preciseFilamentMove)
            toolhead.waitForMovesToFinish()

            if sensorBeforeExtruder.isFilamentPresent == false {
                break
            }
        }

        if sensorBeforeExtruder.isFilamentPresent {
            throw UnloadingError.failedToUnloadFromPosition(.sensorBeforeExtruder)
        }

        return encoder.distance
    }
    
    @discardableResult
    func unloadFilamentFromPTFETubeRaw(longEnoughForRoughSpeed: Bool) throws -> Float {
        let toolhead = context.toolhead
        let encoder = context.encoder
        let feeder = context.feeder

        let numberOfIterations: Int

        if longEnoughForRoughSpeed {
            let distance = distance(from: .inTube, to: .encoder, adjustment: roughTubeMoveBreathingRoom)

            let distanceMoved = try rawMove(for: distance, motor: .feeder, speed: settings.speeds.roughFilamentMove, acceleration: feederAcceleration)
            let absoluteDelta = abs(distance - distanceMoved)

            numberOfIterations = Int((roughTubeMoveBreathingRoom + absoluteDelta) / babyStep) + 15
        } else {
            let distance = distance(from: .inTube, to: .encoder)
            numberOfIterations = Int(distance / babyStep) + 15
        }

        for _ in 0..<numberOfIterations {
            encoder.resetPulseCount()
            feeder.move(to: -babyStep, speed: 60.0, acceleration: feederAcceleration)
            toolhead.waitForMovesToFinish()
                        
            if encoder.distance == 0.0 {
                break
            }
        }

        encoder.resetPulseCount()
        feeder.move(to: 30.0, speed: settings.speeds.preciseFilamentMove, acceleration: feederAcceleration)
        toolhead.waitForMovesToFinish()

        let distanceMoved = encoder.distance
        
        if distanceMoved == 0.0 {
            throw UnloadingError.failedToLoadFilamentBackToPosition(.encoder)
        }

        return distanceMoved
    }

    func unloadFromEncoderRaw() throws {
        let toolhead = context.toolhead
        let encoder = context.encoder
        let feeder = context.feeder

        for _ in 0..<30 {
            encoder.resetPulseCount()
            feeder.move(to: -2.0, speed: 20.0, acceleration: feederAcceleration)
            toolhead.waitForMovesToFinish()
                        
            if encoder.distance == 0.0 {
                break
            }
        }

        let parkingDistance = distance(from: .encoder, to: .parking)
        feeder.move(to: parkingDistance, speed: 20.0, acceleration: feederAcceleration)
        toolhead.waitForMovesToFinish()
    }

    @discardableResult
    func rawMove(for distance: Float, motor: Motor, speed: Float, acceleration: Float) throws -> Float {
        let feeder = context.feeder
        let toolhead = context.toolhead
        let encoder = context.encoder

        encoder.resetPulseCount()
        defer {
            encoder.resetPulseCount()
        }

        switch motor {
            case [.feeder, .extruder]:
                feeder.synchronize()
                defer {
                    feeder.resetSynchronization()
                }
                toolhead.extrude(distance: distance, speed: speed)
            
            case .feeder:
                feeder.resetSynchronization()
                feeder.move(to: distance, speed: speed, acceleration: acceleration)
            
            case .extruder:
                feeder.resetSynchronization()
                toolhead.extrude(distance: distance, speed: speed)

            default:
                break
        }

        let distanceMoved = encoder.distance

        if distanceMoved == 0.0 {
            throw GeneralError.noRawMovement
        }

        return distanceMoved
    }
}
