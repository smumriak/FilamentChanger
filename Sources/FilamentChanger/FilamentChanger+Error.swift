//
//  FilamentChanger+Error.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 20.09.2023
//

extension FilamentChanger {
    enum GeneralError: Swift.Error {
        case noRawMovement
    }

    enum ConfigurationError: Swift.Error {
        enum MissingObject {
            case sensorBeforeExtruder
            case sensorAfterExtruder
        }

        case missingSensor(MissingObject)
        case missingDistance(Position)
    }

    enum UnloadingError: Swift.Error {
        case failedToUnloadFromPosition(Position)
        case failedToLoadFilamentBackToPosition(Position)
        case failedHomingTest
    }

    enum LoadingError: Swift.Error {
        case failedToLoadToPosition(Position)
    }
}
