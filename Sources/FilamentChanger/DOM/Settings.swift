//
//  Settings.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

struct Settings: Codable {
    var distances: Distances
    var loadingSequence: [FilamentChanger.Position]

    var servoAngles: ServoAngles

    init() {
        distances = Distances(parking: 0.0, encoder: 0.0, extruder: 0.0, coolingTube: 0.0, hotend: 0.0)
        loadingSequence = []
        servoAngles = ServoAngles(up: 0.0, down: 0.0)
    }
}

extension Settings {
    // distance for each position is measured from the feeder gears, i.e. from the point when filament can be reliably grabbed by the gears
    struct Distances: Codable, Hashable {
        var parking: Float
        var encoder: Float
        var sensorBeforeExtruder: Float?
        var extruder: Float
        var sensorAfterExtruder: Float?
        var coolingTube: Float
        var hotend: Float
    }
}

extension Settings.Distances {
    subscript(position: FilamentChanger.Position) -> Float {
        get {
            switch position {
                case .unknown:
                    return 0.0

                case .parking:
                    return parking

                case .encoder:
                    return encoder

                case .inTube:
                    return (sensorBeforeExtruder ?? extruder) - 1.0

                case .sensorBeforeExtruder:
                    return sensorBeforeExtruder ?? extruder

                case .atExtruder:
                    return extruder
                    
                case .inExtruder:
                    return extruder + 5.0

                case .sensorAfterExtruder:
                    return sensorAfterExtruder ?? extruder

                case .coolingTube:
                    return coolingTube

                case .hotend:
                    return hotend
            }
        }
        set {
            switch position {
                case .unknown:
                    break

                case .parking:
                    parking = newValue

                case .encoder:
                    encoder = newValue

                case .inTube:
                    if sensorBeforeExtruder != nil {
                        sensorBeforeExtruder = newValue + 1
                    } else {
                        extruder = newValue + 1
                    }

                case .sensorBeforeExtruder:
                    sensorBeforeExtruder = newValue

                case .atExtruder:
                    extruder = newValue

                case .inExtruder:
                    extruder = newValue - 5.0

                case .sensorAfterExtruder:
                    sensorAfterExtruder = newValue

                case .coolingTube:
                    coolingTube = newValue

                case .hotend:
                    hotend = newValue
            }
        }
    }
}

extension Settings {
    struct ServoAngles: Codable, Hashable {
        var up: Float
        var down: Float
    }
}
