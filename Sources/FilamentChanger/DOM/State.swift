//
//  State.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

extension FilamentChanger {
    struct State: Codable, Hashable {
        var filamentPosition: Position = .unknown
        var servoPosition: Klipper.Servo.Position = .unknown
        var positionAdjustment: Float = 0.0
        var tool: UInt? = nil
        var isSelectorHomed: Bool = false
    }
}
