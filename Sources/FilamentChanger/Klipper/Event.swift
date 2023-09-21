//
//  Event.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 12.08.2023
//

extension Klipper {
    struct Event: RawRepresentable, Codable {
        let rawValue: String
        
        init(rawValue: String) {
            self.rawValue = rawValue
        }

        init(_ rawValue: String) {
            self.rawValue = rawValue
        }

        static let connect = Self("klippy:connect")
        static let disconnect = Self("klippy:disconnect")
        static let ready = Self("klippy:ready")

        static let idleStatePrinting = Self("idle_timeout:printing")
        static let idleStateReady = Self("idle_timeout:ready")
        static let idleStateIdle = Self("idle_timeout:idle")
    }
}
