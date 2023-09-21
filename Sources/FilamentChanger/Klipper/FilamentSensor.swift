//
//  FilamentSensor.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

import PythonKit

extension Klipper {
    struct FilamentSensor: KlipperObject {
        var object: PythonObject
        let throwing: ThrowingPythonObject
        let checking: CheckingPythonObject
        let runoutHelper: RunoutHelper

        init(_ object: PythonObject) {
            throwing = object.throwing
            checking = object.checking
            self.object = object

            runoutHelper = RunoutHelper(object.runout_helper)
        }

        @_transparent
        var isFilamentPresent: Bool {
            get {
                runoutHelper.isFilamentPresent
            }
            set {
                runoutHelper.isFilamentPresent = newValue
            }
        }

        @_transparent
        var shouldPauseOnRunout: Bool {
            get {
                runoutHelper.shouldPauseOnRunout
            }
            nonmutating set {
                runoutHelper.shouldPauseOnRunout = newValue
            }
        }

        @_transparent
        var isEnabled: Bool {
            get {
                runoutHelper.isEnabled
            }
            nonmutating set {
                runoutHelper.isEnabled = newValue
            }
        }

        @discardableResult
        func withPauseOnRunoutDisabled<R>(_ body: () throws -> (R)) rethrows -> R {
            let originalValue = shouldPauseOnRunout
            defer {
                shouldPauseOnRunout = originalValue
            }
            return try body()
        }

        @discardableResult
        func withSensorDisabled<R>(_ body: () throws -> (R)) rethrows -> R {
            let originalValue = isEnabled
            defer {
                isEnabled = originalValue
            }
            return try body()
        }
    }

    struct RunoutHelper: KlipperObject {
        var object: PythonObject
        let throwing: ThrowingPythonObject
        let checking: CheckingPythonObject

        init(_ object: PythonObject) {
            throwing = object.throwing
            checking = object.checking
            self.object = object
        }

        var isFilamentPresent: Bool {
            get {
                Bool(object.filament_present)!
            }
            nonmutating set {
                object.filament_present = newValue.pythonObject
            }
        }

        var shouldPauseOnRunout: Bool {
            get {
                Bool(object.runout_pause)!
            }
            nonmutating set {
                object.runout_pause = newValue.pythonObject
            }
        }

        var isEnabled: Bool {
            get {
                Bool(object.sensor_enabled)!
            }
            nonmutating set {
                object.sensor_enabled = newValue.pythonObject
            }
        }
    }
}

extension Optional where Wrapped == Klipper.FilamentSensor {
    @discardableResult
    func withPauseOnRunoutDisabled<R>(_ body: () throws -> (R)) rethrows -> R {
        switch self {
            case .some(let value):
                return try value.withPauseOnRunoutDisabled(body)

            case .none:
                return try body()
        }
    }

    @discardableResult
    func withSensorDisabled<R>(_ body: () throws -> (R)) rethrows -> R {
        switch self {
            case .some(let value):
                return try value.withSensorDisabled(body)

            case .none:
                return try body()
        }
    }
}
