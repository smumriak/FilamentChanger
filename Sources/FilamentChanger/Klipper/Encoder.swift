//
//  Encoder.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

import PythonKit

extension Klipper {
    struct Encoder: KlipperObject {
        var object: PythonObject
        let throwing: ThrowingPythonObject
        let checking: CheckingPythonObject

        init(_ object: PythonObject) throws {
            throwing = object.throwing
            checking = object.checking
            self.object = object

            get_counts = object.get_counts
            set_counts = object.set_counts
            reset_counts = object.reset_counts
            get_distance = object.get_distance
            set_distance = object.set_distance
            is_enabled = object.is_enabled
            get_clog_detection_length = object.get_clog_detection_length
            set_clog_detection_length = object.set_clog_detection_length
            update_clog_detection_length = object.update_clog_detection_length

            object.set_extruder("extruder")
        }

        private let get_counts: PythonObject
        private let set_counts: PythonObject
        private let reset_counts: PythonObject
        private let get_distance: PythonObject
        private let set_distance: PythonObject
        private let is_enabled: PythonObject
        private let get_clog_detection_length: PythonObject
        private let set_clog_detection_length: PythonObject
        private let update_clog_detection_length: PythonObject

        var distance: Float {
            get {
                Float(get_distance())!
            }
            nonmutating set {
                set_distance(newValue)
            }
        }

        var pulseCount: UInt {
            get {
                UInt(get_counts())!
            }
            nonmutating set {
                set_counts(newValue)
            }
        }

        func resetPulseCount() {
            reset_counts()
        }

        var isEnabled: Bool {
            Bool(is_enabled())!
        }

        var clogDetectionLength: Float {
            get {
                Float(get_clog_detection_length())!
            }
            set {
                set_clog_detection_length(newValue)
            }
        }

        func updateClogDetectionLength() {
            update_clog_detection_length()
        }
    }
}
