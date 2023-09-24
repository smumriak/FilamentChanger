//
//  Context.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

struct Context {
    let printer: Klipper.Printer
    let gCode: Klipper.GCode
    let reactor: Klipper.Reactor
    let config: Klipper.Config
    let servo: Klipper.Servo
    let encoder: Klipper.Encoder
    let sensorBeforeExtruder: Klipper.FilamentSensor?
    let sensorAfterExtruder: Klipper.FilamentSensor?
    let extruder: Klipper.ManualStepper
    let feeder: Klipper.SynchronizedManualStepper
    let selector: Klipper.ManualStepper
    let toolhead: Klipper.Toolhead
    let variablesStorage: Klipper.VariablesStorage

    init(_ config: Klipper.Config) throws {
        printer = config.printer
        gCode = try .init(config.checking.gCode!)
        reactor = try .init(config.checking.reactor!)
        self.config = config
        servo = try printer.lookupObject(named: "ercf_servo ercf_servo")
        encoder = try printer.lookupObject(named: "ercf_encoder ercf_encoder")
        sensorBeforeExtruder = try? printer.lookupObject(named: "filament_switch_sensor sensorBeforeExtruder")
        sensorAfterExtruder = try? printer.lookupObject(named: "filament_switch_sensor sensorAfterExtruder")
        extruder = try printer.lookupObject(named: "extruder")
        feeder = try printer.lookupObject(named: "feeder")
        selector = try printer.lookupObject(named: "selector")
        toolhead = try printer.lookupObject(named: "toolhead")
        variablesStorage = try printer.lookupObject(named: "save_variables")
    }
}
