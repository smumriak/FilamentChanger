//
//  FilamentMoveOperation.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

struct FilamentMoveOperation: Operation {
    let speed: Float
    let distance: Float
    let motor: Motor

    func perform(in context: Context, filamentChanger: FilamentChanger) throws {
    }
}
