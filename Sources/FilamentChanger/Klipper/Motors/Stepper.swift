//
//  Stepper.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 21.09.2023
//

import PythonKit

extension Klipper {
    struct Stepper: KlipperObject {
        // MCU_stepper
        var object: PythonObject
        let throwing: ThrowingPythonObject
        let checking: CheckingPythonObject

        init(_ object: PythonObject) {
            throwing = object.throwing
            checking = object.checking
            self.object = object

            get_step_dist = object.get_step_dist
            get_mcu_position = object.get_mcu_position
        }

        private let get_step_dist: PythonObject
        private let get_mcu_position: PythonObject

        var stepLength: Float {
            Float(get_step_dist())!
        }

        var mcuPosition: Int64 {
            Int64(get_mcu_position())!
        }

        @_transparent
        func withCountedSteps(_ body: () throws -> ()) rethrows -> Int64 {
            let position = mcuPosition
            try body()
            return mcuPosition - position
        }

        @_disfavoredOverload
        @_transparent
        func withCountedSteps<R>(_ body: () throws -> (R)) rethrows -> (steps: Int64, result: R) {
            let position = mcuPosition
            let result = try body()
            return (steps: mcuPosition - position, result: result)
        }
    }
}
