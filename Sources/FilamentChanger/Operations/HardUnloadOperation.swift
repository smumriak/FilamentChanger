//
//  HardUnloadOperation.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 19.09.2023
//

struct HardUnloadOperation: Operation {
    func perform(in context: Context, filamentChanger: FilamentChanger) throws {
        // try unloadFilamentFromExtruder(in: context, filamentChanger: filamentChanger)
        // try unloadFromEncoder(in: context, filamentChanger: filamentChanger)
        // try unloadWithHoming(in: context, filamentChanger: filamentChanger)
    }
}

extension FilamentChanger {
    func hardUnload() throws {
        let sensorBeforeExtruder = context.sensorBeforeExtruder
        let sensorAfterExtruder = context.sensorAfterExtruder

        try sensorBeforeExtruder.withPauseOnRunoutDisabled {
            try sensorAfterExtruder.withPauseOnRunoutDisabled {
                let isDeepInTube: Bool

                currentState.positionAdjustment = 0.0

                // first part is going to happen purely on extruder
                changeServoPosition(to: .up)
                defer {
                    // intentional safety
                    changeServoPosition(to: .up)
                }

                if isFilamentInExtruder {
                    unloadFilamentFromHotentRaw()
                    currentState.filamentPosition = .coolingTube

                    // this error does not matter since we will try to pull it out from extruder anyway
                    try? withRetry(count: 2) {
                        try unloadFilamentFromSensorAfterExtruderRaw()
                    }

                    currentState.filamentPosition = .inExtruder
                    
                    do {
                        try withRetry(count: 3) {
                            try unloadFilamentFromExtruderRaw()
                        }

                        currentState.filamentPosition = .atExtruder
                    } catch {
                        currentState.filamentPosition = .inExtruder
                        // this is quite bad. if after three attempts the thing could not be unloaded it means there are some weird shenanigans going on because
                        throw error
                    }
                    isDeepInTube = true
                } else if let sensorBeforeExtruder, sensorBeforeExtruder.isFilamentPresent == true {
                    currentState.filamentPosition = .sensorBeforeExtruder
                    isDeepInTube = true
                } else if isFilamentInEncoder {
                    currentState.filamentPosition = .inTube
                    isDeepInTube = false
                } else {
                    isDeepInTube = false
                }

                // second part is happening using synchronized motion
                // either we remove filament from sensor before extruder (if one is present)
                // or we synchronyze motion of extuder and feeder to retract 5mm to get it out for sure
                changeServoPosition(to: .down)

                if [.inTube, .sensorBeforeExtruder].contains(currentState.filamentPosition) {
                    if context.sensorBeforeExtruder != nil {
                        // this error does not matter since we will try to pull it from the PTFE tube anyway
                        try? withRetry(count: 2) {
                            try unloadFilamentFromSensorBeforeExtruderRaw()
                        }
                    } else {
                        // this error does not matter since we will try to pull it from the PTFE tube anyway
                        try? withRetry(count: 2) {
                            try rawMove(for: 5.0, motor: [.feeder, .extruder], speed: settings.speeds.preciseFilamentMove, acceleration: feederAcceleration)
                        }
                    }

                    currentState.filamentPosition = .inTube
                }

                // third part is when we actually unload the PTFE tube and encoder
                // we want to check if filament is still in encoder tho
                if currentState.filamentPosition == .inTube {
                    try unloadFilamentFromPTFETubeRaw(longEnoughForRoughSpeed: isDeepInTube)
                    try unloadFromEncoderRaw()
                }

                // final part is to perform the homing test. if homing move creates more than 10mm of movements we've successfully pulled filament out

                try unloadWithHomingTest()
            }
        }
    }

    func formTip() throws {
        let none: String? = nil
        print(none!)
    }

    func unloadFilamentFromHotent() throws {
        changeServoPosition(to: .up)

        unloadFilamentFromHotentRaw()
            
        currentState.filamentPosition = .coolingTube
        currentState.positionAdjustment = 0.0
    }

    func unloadFilamentFromExtruder() throws {
        if isFilamentInExtruder == false {
            return
        }
      
        changeServoPosition(to: .up)

        do {
            try formTip()
        } catch {
            unloadFilamentFromHotentRaw()
        }

        currentState.filamentPosition = .coolingTube

        do {
            try unloadFilamentFromExtruderRaw()

            currentState.filamentPosition = .atExtruder
            currentState.positionAdjustment = 0.0
        } catch {
            currentState.filamentPosition = .unknown
            currentState.positionAdjustment = 0.0

            throw error
        }
    }

    func unloadFilamentFromPTFETube(longEnoughForRoughSpeed: Bool) throws {
        if isFilamentInEncoder == false {
            return
        }
        do {
            try withServoDown {
                try unloadFilamentFromPTFETubeRaw(longEnoughForRoughSpeed: longEnoughForRoughSpeed)
            }

            currentState.filamentPosition = .encoder
            currentState.positionAdjustment = context.encoder.distance
        } catch {
            currentState.filamentPosition = .unknown
            currentState.positionAdjustment = 0.0

            throw error
        }
    }

    func unloadFromEncoder() throws {
        if isFilamentInEncoder == false {
            return
        }

        do {
            try withServoDown {
                try unloadFromEncoderRaw()
            }

            currentState.filamentPosition = .parking
            currentState.positionAdjustment = 0.0
        } catch {
            currentState.filamentPosition = .unknown
            currentState.positionAdjustment = 0.0

            throw error
        }
    }

    func unloadWithHomingTest() throws {
        let toolhead = context.toolhead
        let feeder = context.feeder
        let selector = context.selector

        feeder.resetSynchronization()

        for _ in 0..<15 {
            changeServoPosition(to: .up)
            feeder.position = 0.0
            feeder.homingMove(to: 10.0, speed: 60.0, acceleration: feederAcceleration)
            toolhead.dwell(for: .milliseconds(200))

            var distanceMoved = abs(selector.position)

            feeder.position = 0.0
            feeder.homingMove(to: -10.0, speed: 60.0, acceleration: feederAcceleration)
            toolhead.dwell(for: .milliseconds(200))

            distanceMoved += abs(selector.position)

            if distanceMoved < 10.0 {
                withServoDown {
                    feeder.move(to: -3.0, speed: 20.0, acceleration: feederAcceleration)
                    toolhead.waitForMovesToFinish()
                }
                continue
            } else {
                currentState.filamentPosition = .parking
                currentState.positionAdjustment = 0.0

                return
            }
        }

        currentState.filamentPosition = .unknown
        currentState.positionAdjustment = 0.0

        throw UnloadingError.failedHomingTest
    }
}
