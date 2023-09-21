//
//  HomeSelectorOperation.swift
//  FilamentChanger
//
//  Created by Serhii Mumriak on 20.09.2023
//

struct HomeSelectorOperation: Operation {
    func perform(in context: Context, filamentChanger: FilamentChanger) throws {
        try filamentChanger.homeSelector()
    }
}

extension FilamentChanger {
    func homeSelector(force: Bool = false, hardUnloadFilament: Bool = false) throws {
        if currentState.isSelectorHomed == true && force == false {
            return
        }
    }
}
