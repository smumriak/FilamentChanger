//
//  Toolhead.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

import PythonKit

extension Klipper {
    struct Toolhead: KlipperObject {
        typealias Position = (x: Float, y: Float, z: Float, e: Float)

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
            dwell = object.dwell
            wait_moves = object.wait_moves
            manual_move = object.manual_move
        }

        private let get_position: PythonObject
        private let set_position: PythonObject
        private let do_set_position: PythonObject
        private let dwell: PythonObject
        private let wait_moves: PythonObject
        private let manual_move: PythonObject

        var position: Position {
            get {
                let positionArray: [Float] = Array(get_position())!
                return (positionArray[0], positionArray[1], positionArray[2], positionArray[3])
            }
            nonmutating set {
                let positionArray: [Float] = [newValue.x, newValue.y, newValue.z, newValue.e]
                set_position(positionArray)
            }
        }

        func dwell(for duration: Duration) {
            let timeinterval = Float(duration.components.seconds) + Float(duration.components.attoseconds) * 1e-18
            dwell(for: timeinterval)
        }

        func dwell(for time: Float) {
            dwell(time)
        }

        func waitForMovesToFinish() {
            wait_moves()
        }

        func manualMove(to position: Position, speed: Float) {
            let positionArray = [position.x, position.y, position.z, position.e]
            manual_move(positionArray, speed)
        }

        func extrude(distance: Float, speed: Float) {
            var position = position
            position.e += distance

            manualMove(to: position, speed: speed)
        }
    }
}
