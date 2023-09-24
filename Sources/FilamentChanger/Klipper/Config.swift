//
//  Config.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 12.08.2023
//

import PythonKit

extension Klipper {
    struct Config: KlipperObject {
        var object: PythonObject
        let throwing: ThrowingPythonObject
        let checking: CheckingPythonObject

        let printer: Printer
        
        init(_ object: PythonObject) throws {
            throwing = object.throwing
            checking = object.checking
            self.object = object

            printer = try Printer(object.get_printer())

            print("Hi")

            getint = object.getint
            getfloat = object.getfloat
            getstring = object.get
            getintlist = object.getintlist
        }

        private let getint: PythonObject
        private let getfloat: PythonObject
        private let getstring: PythonObject
        private let getintlist: PythonObject

        subscript(key: String) -> Int {
            Int(getint(key))!
        }

        subscript(key: String) -> Float {
            Float(getfloat(key))!
        }

        subscript(key: String) -> String {
            String(getstring(key))!
        }

        subscript(key: String) -> [Int] {
            Array(getintlist(key))!
        }
    }
}
