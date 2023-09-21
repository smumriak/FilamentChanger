//
//  Operation.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 30.08.2023
//

protocol Operation: Codable {
    func perform(in context: Context, filamentChanger: FilamentChanger) throws
    var retryCount: UInt { get }
}

extension Operation {
    var retryCount: UInt { 0 }
}
