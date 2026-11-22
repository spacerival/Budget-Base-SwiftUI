//
//  BudgetCalculations.swift
//  BudgetBase
//
//  Created by Andrew Lee on 11/17/26.
//

import Foundation

struct CategoryTotal: Identifiable {
    let name: String
    let amount: Double
    
    var id: String { name }
}
struct Period: Identifiable {
    let start: Date
    let transactions: [Transaction]
    
    var id: Date { start }
    
    var income: Double {
        transactions.income.total
    }
    var expenses: Double {
        transactions.expenses.total
    }
    var savings: Double {
        transactions.expenses.inCategories(SpendingGroup.savings.categories).total
    }
}

extension Array where Element == Transaction {
    var total: Double {
        reduce(0) { $0 + $1.amount }
    }
    var income: [Transaction] {
        filter { $0.type == .income }
    }
    var expenses: [Transaction] {
        filter { $0.type == .expense }
    }
    
    func inCategories(_ categories: Set<String>) -> [Transaction] {
        filter { categories.contains($0.category) }
    }
    func inMonth(of date: Date = .now) -> [Transaction] {
        filter { Calendar.current.isDate($0.date, equalTo: date, toGranularity: .month) }
    }
    
    var categoryTotals: [CategoryTotal] {
        Dictionary(grouping: self, by: \.category)
            .map { CategoryTotal(name: $0.key, amount: $0.value.total) }
            .sorted { $0.amount == $1.amount ? $0.name < $1.name : $0.amount > $1.amount }
    }
}

extension TransactionStore {
    var income: [Transaction] {
        transactions.income
    }
    var expenses: [Transaction] {
        transactions.expenses
    }
    
    func incomeThisMonth(_ date: Date = .now) -> Double {
        income.inMonth(of: date).total
    }
    
    func expensesThisMonth(_ date: Date = .now) -> [Transaction] {
        expenses.inMonth(of: date)
    }
    
    func periods(for range: TimeRange, endingAt date: Date = .now) -> [Period] {
        let calendar = Calendar.current
        guard let current = calendar.dateInterval(of: range.component, for: date) else { return [] }
        return (0..<range.periodCount).reversed().compactMap { offset in
            guard let start = calendar.date(byAdding: range.component, value: -offset, to: current.start),
                  let interval = calendar.dateInterval(of: range.component, for: start) else { return nil }
            let matching = transactions.filter { $0.date >= interval.start && $0.date < interval.end }
            return Period(start: interval.start, transactions: matching)
        }
    }
}
