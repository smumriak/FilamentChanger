//
//  Printer.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 12.08.2023
//

import PythonKit

extension Klipper {
    struct Printer: KlipperObject {
        var object: PythonObject
        let throwing: ThrowingPythonObject
        let checking: CheckingPythonObject

        init(_ object: PythonObject) throws {
            throwing = object.throwing
            checking = object.checking
            self.object = object
        }

        func registerCallbackForEvent(_ event: Klipper.Event, _ callback: @escaping () throws -> ()) throws {
            let function = PythonFunction { arguments in
                try callback()
                print("Number of arguments: \(arguments.count)")
                return 0
            }

            object.register_event_handler(event.rawValue, function.pythonObject)
        }

        func lookupObject(named objectName: String) throws -> PythonObject {
            try object.lookup_object.throwing.dynamicallyCall(withArguments: [objectName])
        }

        func lookupObject<T: KlipperObject>(named objectName: String) throws -> T {
            try T(object.lookup_object.throwing.dynamicallyCall(withArguments: [objectName]))
        }
    }
}
