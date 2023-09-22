//
//  ManualStepper.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

import PythonKit

extension Klipper {
    struct ManualStepper: KlipperObject {
        // ManualStepper
        var object: PythonObject
        let throwing: ThrowingPythonObject
        let checking: CheckingPythonObject

        init(_ object: PythonObject) {
            throwing = object.throwing
            checking = object.checking
            self.object = object
            get_position = object.get_position
            set_position = object.set_position
            do_set_position = object.do_set_position
            do_move = object.do_move
            do_homing_move = object.do_homing_move

            stepper = Stepper(object.steppers[0])
        }

        private let get_position: PythonObject
        private let set_position: PythonObject
        private let do_set_position: PythonObject
        private let do_move: PythonObject
        private let do_homing_move: PythonObject

        let stepper: Stepper

        var position: Float {
            // klipper API is quite bad
            // get_position returns array of four floats: [<actual position>, 0.0, 0.0, 0.0]
            // set_position assumes input to be an array of at least one float. it forwards that single float to do_set_position method
            // do_set_position creates array of three (YES THREE) elements and sends it to underlying "rail", like this: [<actual position>, 0.0, 0.0]
            // essentially get_position is a terrible getter and do_set_position is a terrible setter. actual set_position should not be used

            get {
                let positionArray: [Float] = Array(get_position())!
                return positionArray[0]
            }
            nonmutating set {
                do_set_position(newValue)
            }
        }

        func move(to position: Float, speed: Float, acceleration: Float) {
            do_move(position, speed, acceleration)
        }

        func homingMove(to position: Float, speed: Float, acceleration: Float) {
            do_homing_move(position, speed, acceleration, true, true)
        }
    }
}
