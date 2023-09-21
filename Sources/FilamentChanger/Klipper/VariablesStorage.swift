//
//  VariablesStorage.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

import PythonKit

extension Klipper {
    struct VariablesStorage: KlipperObject {
        var object: PythonObject
        let throwing: ThrowingPythonObject
        let checking: CheckingPythonObject

        init(_ object: PythonObject) {
            throwing = object.throwing
            checking = object.checking
            self.object = object
            get = object.get
            set = object.set
        }

        private let get: PythonObject
        private let set: PythonObject

        subscript<T: PythonConvertible & ConvertibleFromPython>(key: Key, default: T? = nil) -> T {
            get {
                if let `default` {
                    return T(get(key.rawValue, `default`))!
                } else {
                    return T(get(key.rawValue))!
                }
            }
            nonmutating set {
                set(key.rawValue, newValue)
            }
        }
    }
}

extension Klipper.VariablesStorage {
    struct Key: RawRepresentable {
        let rawValue: String
    }
}
