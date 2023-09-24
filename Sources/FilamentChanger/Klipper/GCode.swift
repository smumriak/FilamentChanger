//
//  GCode.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 12.08.2023
//

import PythonKit

extension Klipper {
    struct GCode: KlipperObject {
        var object: PythonObject
        let throwing: ThrowingPythonObject
        let checking: CheckingPythonObject

        init(_ object: PythonObject) throws {
            throwing = object.throwing
            checking = object.checking
            self.object = object

            register_command = object.register_command
        }

        private let register_command: PythonObject

        func registerCommand(_ command: String, description: String = "No Desription", _ callback: @escaping () throws -> ()) throws {
            let function = PythonFunction { arguments in
                try callback()
                print("Number of arguments: \(arguments.count)")
                return 0
            }

            register_command(command, function.pythonObject, description)
        }
    }
}
