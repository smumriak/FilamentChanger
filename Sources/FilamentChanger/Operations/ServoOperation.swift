//
//  ServoOperation.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

struct ServoOperation: Operation {
    let position: Klipper.Servo.Position

    func perform(in context: Context, filamentChanger: FilamentChanger) throws {
        filamentChanger.changeServoPosition(to: position)
    }
}

extension FilamentChanger {
    func changeServoPosition(to position: Klipper.Servo.Position) {
        let servo = context.servo
        
        if currentState.servoPosition == position {
            return
        }

        let angle: Float
        switch position {
            case .unknown, .up:
                angle = settings.servoAngles.up

            case .down:
                angle = settings.servoAngles.down
        }
        
        servo.changeAngle(to: angle)

        switch position {
            case .unknown, .up:
                currentState.servoPosition = .up
                servo.disable()

            case .down:
                currentState.servoPosition = .down
        }
    }

    @discardableResult
    @_transparent
    func withServoDown<R>(_ body: () throws -> (R)) rethrows -> R {
        changeServoPosition(to: .down)
        defer {
            changeServoPosition(to: .up)
        }
        return try body()
    }
}
