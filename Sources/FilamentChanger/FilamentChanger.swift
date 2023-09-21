//
//  FilamentChanger.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 12.08.2023
//

import Python
import PythonKit
import Foundation

// use this code to extract arguments from python tuples. if function prototype on python side has only single argument it will NOT be wrapped inside tuple
// var configObject: UnsafeMutablePointer<PyObject>? = nil
// _ = "".withCString { format in
//     withUnsafePointer(to: &configObject) {
//         withVaList([$0]) {
//             PyArg_VaParse(arguments, format, $0)
//         }
//     }
// }

func passErrorToPython(_ error: some Error) {
    error.localizedDescription.withCString {
        PyErr_SetString(PyExc_RuntimeError, $0)
    }
}

func pyThrow<R>(_ body: () throws -> (R)) -> R? {
    do {
        return try body()
    } catch {
        passErrorToPython(error)
        return nil
    }
}

@_cdecl("createFilamentChanger")
func createFilamentChanger(_ configObject: UnsafeMutablePointer<PyObject>) -> UnsafeMutableRawPointer? {
    let config = Klipper.Config(PythonObject(configObject))
    return pyThrow {
        let filamentChanger = try FilamentChanger(config)
        return Unmanaged.passRetained(filamentChanger).toOpaque()
    }
}

@_cdecl("releaseFilamentChanger")
func releaseFilamentChanger(_ pointer: UnsafeMutableRawPointer) {
    Unmanaged<FilamentChanger>.fromOpaque(pointer).release()
}

final class FilamentChanger {
    let config: Klipper.Config
    let printer: Klipper.Printer

    private var _context: Context!
    var context: Context { _context }
    var currentState = State()

    var settings: Settings = Settings()

    deinit {
        print("Deallocating class FilamentChanger inside swift while being called from python!")
    }

    init(_ config: Klipper.Config) throws {
        print("Instantiating class FilamentChanger inside swift while being called from python!")

        self.config = config
        self.printer = config.printer

        try registerForEvents()
    }

    func distance(to position: Position, adjustment: Float? = nil) -> Float {
        if position == .unknown { return 0.0 }

        switch currentState.filamentPosition {
            case .unknown:
                return 0.0

            case let value:
                return settings.distances[value] - settings.distances[value] - (adjustment ?? currentState.positionAdjustment)
        }
    }

    // MARK: Events handling
    
    func registerForEvents() throws {
        try printer.registerCallbackForEvent(.connect) { [unowned self] in
            self.handleConnectEvent()
        }
        try printer.registerCallbackForEvent(.disconnect) { [unowned self] in
            self.handleDisconnectEvent()
        }
        try printer.registerCallbackForEvent(.ready) { [unowned self] in
            self.handleReadyEvent()
        }
    }

    func handleConnectEvent() {
        if _context != nil { return }

        pyThrow {
            _context = try Context(config)

            if settings.loadingSequence.contains(.sensorBeforeExtruder) {
                if context.sensorBeforeExtruder == nil {
                    throw ConfigurationError.missingSensor(.sensorBeforeExtruder)
                }

                if settings.distances.sensorBeforeExtruder == nil {
                    throw ConfigurationError.missingDistance(.sensorBeforeExtruder)
                }
            }

            if settings.loadingSequence.contains(.sensorAfterExtruder) {
                if context.sensorAfterExtruder == nil {
                    throw ConfigurationError.missingSensor(.sensorAfterExtruder)
                }

                if settings.distances.sensorAfterExtruder == nil {
                    throw ConfigurationError.missingDistance(.sensorAfterExtruder)
                }
            }
        }
    }

    func handleDisconnectEvent() {
        pyThrow {
        }
    }

    func handleReadyEvent() {
        pyThrow {
            // throw ConfigurationError.missingDistance(.coolingTube)
        }
    }

    func uncheckedExecute(_ operations: [any Operation]) throws {
        for operation in operations {
            context.encoder.distance = 0.0

            try withRetry(count: operation.retryCount) {
                try operation.perform(in: context, filamentChanger: self)
            }
        }
    }

    func execute(_ operations: [any Operation], recovery: (any Swift.Error) -> () = { _ in }) {
        do {
            try uncheckedExecute(operations)
        } catch {
            recovery(error)
        }
    }

    var isFilamentInExtruder: Bool {
        // guaranteed known case
        if let sensorAfterExtruder = context.sensorAfterExtruder, sensorAfterExtruder.isFilamentPresent {
            return true
        }

        // guaranteed known case
        if let sensorBeforeExtruder = context.sensorBeforeExtruder, sensorBeforeExtruder.isFilamentPresent == false {
            return false
        }

        let toolhead = context.toolhead
        let encoder = context.encoder

        encoder.resetPulseCount()
        defer {
            encoder.resetPulseCount()
        }

        toolhead.extrude(distance: -(extruderTestDistance + ptfeTubePlay), speed: extrudeTestSpeed)

        let distanceExtruded = encoder.distance

        if distanceExtruded != 0.0 {
            toolhead.extrude(distance: min(extruderTestDistance + ptfeTubePlay, abs(distanceExtruded)), speed: extrudeTestSpeed)
            return true
        } else {
            return false
        }
    }

    var isFilamentInEncoder: Bool {
        let feeder = context.feeder
        let encoder = context.encoder
        let servo = context.servo

        changeServoPosition(to: .down)
        defer {
            changeServoPosition(to: .up)
        }
        
        encoder.resetPulseCount()
        defer {
            encoder.resetPulseCount()
        }

        feeder.move(to: 3.0, speed: extrudeTestSpeed, acceleration: feederAcceleration)

        let distanceMoved = encoder.distance
        if distanceMoved != 0.0 {
            feeder.move(to: -distanceMoved, speed: extrudeTestSpeed, acceleration: feederAcceleration)
            return true
        } else {
            return false
        }
    }
}

func withRetry(count: UInt, body: () throws -> ()) throws {
    // guarantee that numberOfIterations is > 0 on loop start, but less or equal to UInt.max
    let numberOfIterations = min(count, UInt.max - 1) + 1
    var rethrownError: (any Swift.Error)? = nil
    for _ in 0..<numberOfIterations {
        do {
            try body()
            rethrownError = nil
            break
        } catch {
            rethrownError = error
            continue
        }
    }

    if let rethrownError {
        throw rethrownError
    }
}
