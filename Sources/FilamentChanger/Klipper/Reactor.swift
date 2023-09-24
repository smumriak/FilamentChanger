//
//  Reactor.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 12.08.2023
//

import PythonKit

extension Klipper {
    struct Reactor: KlipperObject {
        var object: PythonObject
        let throwing: ThrowingPythonObject
        let checking: CheckingPythonObject

        init(_ object: PythonObject) throws {
            throwing = object.throwing
            checking = object.checking
            self.object = object
        }
    }
}
