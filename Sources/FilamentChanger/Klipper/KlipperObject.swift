//
//  KlipperObject.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 12.08.2023
//

import PythonKit

protocol KlipperObject {
    var object: PythonObject { get }
    var throwing: ThrowingPythonObject { get }
    var checking: CheckingPythonObject { get }

    init(_ object: PythonObject) throws
}
