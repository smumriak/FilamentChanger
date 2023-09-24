//
//  SynchronizedManualStepper.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

import PythonKit

extension Klipper {
    struct SynchronizedManualStepper: KlipperObject {
        private var manualStepper: ManualStepper

        var object: PythonObject {
            get {
                manualStepper.object
            }
            set {
                manualStepper.object = newValue
            }
        }

        var throwing: ThrowingPythonObject { manualStepper.throwing }
        var checking: CheckingPythonObject { manualStepper.checking }

        init(_ object: PythonObject) throws {
            self.manualStepper = try ManualStepper(object)

            sync_to_extruder = object.sync_to_extruder
            reset_synchronization = object.reset_synchronization
        }

        private let sync_to_extruder: PythonObject
        private let reset_synchronization: PythonObject

        var stepper: Stepper {
            manualStepper.stepper
        }

        var position: Float {
            get {
                manualStepper.position
            }
            nonmutating set {
                manualStepper.position = newValue
            }
        }

        func move(to position: Float, speed: Float, acceleration: Float) {
            manualStepper.move(to: position, speed: speed, acceleration: acceleration)
        }

        func homingMove(to position: Float, speed: Float, acceleration: Float) {
            manualStepper.homingMove(to: position, speed: speed, acceleration: acceleration)
        }

        func synchronize(to extruderName: String = "extruder") {
            sync_to_extruder(extruderName)
        }

        func resetSynchronization() {
            reset_synchronization()
        }
    }
}
