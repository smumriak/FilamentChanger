//
//  Servo.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

import PythonKit

extension Klipper {
    struct Servo: KlipperObject {
        var object: PythonObject
        let throwing: ThrowingPythonObject
        let checking: CheckingPythonObject

        init(_ object: PythonObject) throws {
            throwing = object.throwing
            checking = object.checking
            self.object = object

            let printer = try Printer(object.printer)
            toolhead = try printer.lookupObject(named: "toolhead")

            _set_pwm = object._set_pwm
            _get_pwm_from_pulse_width = object._get_pwm_from_pulse_width
            _get_pwm_from_angle = object._get_pwm_from_angle
        }

        private let toolhead: Toolhead

        private let _set_pwm: PythonObject
        private let _get_pwm_from_pulse_width: PythonObject
        private let _get_pwm_from_angle: PythonObject

        func pwmForAngle(_ angle: Float) -> Float {
            Float(_get_pwm_from_angle(angle))!
        }

        func pwmForPulseWidth(_ pulseWidth: Float) -> Float {
            Float(_get_pwm_from_pulse_width(pulseWidth))!
        }

        func setPWM(time: Float, value: Float) {
            _set_pwm(time, value)
        }
        
        func changeAngle(to angle: Float) {
            let lastMoveTime = toolhead.lastMoveTime
            let pwm = pwmForAngle(angle)
            setPWM(time: lastMoveTime, value: pwm)
        }

        func disable() {
            let lastMoveTime = toolhead.lastMoveTime
            let pwm = pwmForPulseWidth(0.0)
            setPWM(time: lastMoveTime, value: pwm)
        }
    }
}

extension Klipper.Servo {
    enum Position: Codable, Hashable {
        case unknown
        case up
        case down
    }
}
