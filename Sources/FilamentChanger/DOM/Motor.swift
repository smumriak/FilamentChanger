//
//  Motor.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

struct Motor: OptionSet, Codable, Hashable {
    let rawValue: UInt

    static let feeder = Self(rawValue: 1 << 0)
    static let extruder = Self(rawValue: 1 << 1)
}
