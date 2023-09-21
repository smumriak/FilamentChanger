//
//  Position.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

extension FilamentChanger {
    enum Position: String, Codable, Hashable {
        case unknown
        case parking
        case encoder
        case inTube
        case sensorBeforeExtruder
        case atExtruder
        case inExtruder
        case sensorAfterExtruder
        case coolingTube
        case hotend
    }
}
