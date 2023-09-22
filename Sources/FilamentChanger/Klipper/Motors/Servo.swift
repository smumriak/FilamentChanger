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

        init(_ object: PythonObject) {
            throwing = object.throwing
            checking = object.checking
            self.object = object
            self.set_value = object.set_value
        }

        private let set_value: PythonObject
        
        func changeAngle(to angle: Float) {
            set_value(angle)
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
