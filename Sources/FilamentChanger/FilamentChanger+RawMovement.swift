//
//  FilamentChanger+RawMovement.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 20.09.2023
//

extension FilamentChanger {
    func unloadFilamentFromHotentRaw() {
        let toolhead = context.toolhead

        toolhead.extrude(distance: softenTheTipDistance, speed: extrudeTestSpeed)
        toolhead.extrude(distance: -(settings.distances[.hotend] - settings.distances[.coolingTube]), speed: extruderYankSpeed)
        toolhead.waitForMovesToFinish()
        toolhead.dwell(for: .seconds(5))
    }

    func unloadFilamentFromSensorAfterExtruderRaw() throws {
        guard let sensorAfterExtruder = context.sensorAfterExtruder else {
            return
        }

        let toolhead = context.toolhead

        for _ in 0..<8 {
            toolhead.extrude(distance: -babyStep, speed: extrudeTestSpeed)
            toolhead.waitForMovesToFinish()

            if sensorAfterExtruder.isFilamentPresent == false {
                break
            }
        }

        if sensorAfterExtruder.isFilamentPresent == true {
            throw UnloadingError.failedToUnloadFromPosition(.sensorAfterExtruder)
        }
    }

    func unloadFilamentFromExtruderRaw() throws {
        let toolhead = context.toolhead
        let encoder = context.encoder

        for _ in 0..<8 {
            encoder.resetPulseCount()
            toolhead.extrude(distance: -20.0, speed: extrudeTestSpeed)
            toolhead.waitForMovesToFinish()

            if encoder.distance == 0.0 {
                break
            }
        }

        if let sensorAfterExtruder = context.sensorAfterExtruder, sensorAfterExtruder.isFilamentPresent == true {
            throw UnloadingError.failedToUnloadFromPosition(.inExtruder)
        }

        if encoder.distance != 0.0 {
            throw UnloadingError.failedToUnloadFromPosition(.inExtruder)
        }
    }

    func unloadFilamentFromSensorBeforeExtruderRaw() throws {
        guard let sensorBeforeExtruder = context.sensorBeforeExtruder else {
            return
        }

        let toolhead = context.toolhead

        for _ in 0..<8 {
            toolhead.extrude(distance: -babyStep, speed: extrudeTestSpeed)
            toolhead.waitForMovesToFinish()

            if sensorBeforeExtruder.isFilamentPresent == false {
                break
            }
        }

        if sensorBeforeExtruder.isFilamentPresent {
            throw UnloadingError.failedToUnloadFromPosition(.sensorBeforeExtruder)
        }
    }
    
    func unloadFilamentFromPTFETubeRaw() throws {
        let toolhead = context.toolhead
        let encoder = context.encoder
        let feeder = context.feeder

        let numberOfIterations = Int(settings.distances[.inTube] / babyStep) + 15
        for _ in 0..<numberOfIterations {
            encoder.resetPulseCount()
            feeder.move(to: -babyStep, speed: 60.0, acceleration: feederAcceleration)
            toolhead.waitForMovesToFinish()
                        
            if encoder.distance == 0.0 {
                break
            }
        }

        encoder.resetPulseCount()
        feeder.move(to: 30.0, speed: 20.0, acceleration: feederAcceleration)
        toolhead.waitForMovesToFinish()
        
        if encoder.distance == 0.0 {
            throw UnloadingError.failedToLoadFilamentBackToPosition(.encoder)
        }
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

        feeder.move(to: -(distanceFromEncoderToPark - encoder.distance), speed: 20.0, acceleration: feederAcceleration)
        toolhead.waitForMovesToFinish()
    }

    func rawMove(for distance: Float, motor: Motor, speed: Float, acceleration: Float) throws {
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

        if encoder.distance == 0.0 {
            throw GeneralError.noRawMovement
        }
    }
}
