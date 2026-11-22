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
    @Published var savingsPercentGoal: Double {
        didSet { defaults.set(savingsPercentGoal, forKey: "savingsPercentGoal") }
    }
    @Published var savingsBlockGoal: Double {
        didSet { defaults.set(savingsBlockGoal, forKey: "savingsBlockGoal") }
    }
    @Published var allocations: [String: Double] {
        didSet { defaults.set(allocations, forKey: "zeroBasedAllocations") }
    }
    
    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        let savedIsBlock = defaults.bool(forKey: "isBlockSavings")
        let legacyGoal = defaults.object(forKey: "savingsGoal") as? Double
        isBlockSavings = savedIsBlock
        savingsPercentGoal = defaults.object(forKey: "savingsPercentGoal") as? Double
            ?? (savedIsBlock ? nil : legacyGoal) ?? 20
        savingsBlockGoal = defaults.object(forKey: "savingsBlockGoal") as? Double
            ?? (savedIsBlock ? legacyGoal : nil) ?? 0
        allocations = defaults.dictionary(forKey: "zeroBasedAllocations") as? [String: Double]
        ?? Dictionary(uniqueKeysWithValues: ZeroBasedCategory.allCases.map { ($0.rawValue, $0.defaultAmount) })
    }
    
    var savingsGoal: Double {
        get { isBlockSavings ? savingsBlockGoal : savingsPercentGoal }
        set {
            if isBlockSavings {
                savingsBlockGoal = newValue
            } else {
                savingsPercentGoal = newValue
            }
        }
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
