//
//  BudgetSettings.swift
//  BudgetBase
//
//  Created by Andrew Lee on 11/17/26.
//

import Foundation
import Combine

class BudgetSettings: ObservableObject {
    private let defaults: UserDefaults
    
    @Published var isBlockSavings: Bool {
        didSet { defaults.set(isBlockSavings, forKey: "isBlockSavings") }
    }
    @Published var savingsGoal: Double {
        didSet { defaults.set(savingsGoal, forKey: "savingsGoal") }
    }
    @Published var allocations: [String: Double] {
        didSet { defaults.set(allocations, forKey: "zeroBasedAllocations") }
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        isBlockSavings = defaults.bool(forKey: "isBlockSavings")
        savingsGoal = defaults.object(forKey: "savingsGoal") as? Double ?? 20
        allocations = defaults.dictionary(forKey: "zeroBasedAllocations") as? [String: Double]
        ?? Dictionary(uniqueKeysWithValues: ZeroBasedCategory.allCases.map { ($0.rawValue, $0.defaultAmount) })
    }
    
    var totalAllocated: Double {
        ZeroBasedCategory.allCases.reduce(0) { $0 + allocation(for: $1) }
    }
    func monthlySavingsGoal(income: Double) -> Double {
        isBlockSavings ? savingsGoal : income * savingsGoal / 100
    }
    func allocation(for category: ZeroBasedCategory) -> Double {
        allocations[category.rawValue] ?? category.defaultAmount
    }
    func setAllocation(_ amount: Double, for category: ZeroBasedCategory) {
        allocations[category.rawValue] = amount
    }
}
