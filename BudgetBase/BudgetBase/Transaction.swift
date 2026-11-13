//
//  Transaction.swift
//  BudgetBase
//
//  Created by Chantal Le on 11/12/26.
//

import Foundation
import SwiftUI

// Income or Expense

enum TransactionType: String, CaseIterable, Identifiable {
    case income = "Income"
    case expense = "Expense"

    var id: String { rawValue }

    // Green for money coming in, red for money going out.
    var color: Color {
        self == .income ? .green : .red
    }

    // The category list changes depending on the type.
    // Replace these with the exact categories from Milestone 1.
    var categories: [String] {
        switch self {
        case .income:
            return ["Salary", "Freelance", "Gift", "Investment", "Other"]
        case .expense:
            return ["Rent", "Groceries", "Utilities", "Dining Out", "Transportation",
                    "Entertainment/Leisure", "Shopping", "Healthcare", "Insurance",
                    "Education", "Savings Account", "Other"]
        }
    }
}

// One Transaction

// The screens all work with this simple struct.
// Only TransactionStore knows about the database version (TransactionEntity).
struct Transaction: Identifiable {
    var id = UUID()          // `var` so a transaction loaded from the database keeps its saved ID
    var name: String         // what the user typed in "Description"
    var amount: Double       // always positive; `type` decides + or -
    var type: TransactionType
    var date: Date
    var category: String
    var notes: String = ""

    // "+$3,020.67" or "-$100.00"
    var signedAmountText: String {
        let sign = type == .income ? "+" : "-"
        return sign + amount.formatted(.currency(code: "USD"))
    }
}

// Starting Data
// Saved into the database the first time the app runs (see TransactionStore).
// Also used by the Detail screen's #Preview.

private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
    Calendar.current.date(from: DateComponents(year: year, month: month, day: day)) ?? Date()
}

extension Transaction {
    static let samples: [Transaction] = [
        Transaction(name: "Savings Account", amount: 100.00, type: .expense,
                    date: makeDate(2026, 9, 6), category: "Savings Account"),
        Transaction(name: "Rent", amount: 500.00, type: .expense,
                    date: makeDate(2026, 9, 6), category: "Rent"),
        Transaction(name: "Dining Out", amount: 434.21, type: .expense,
                    date: makeDate(2025, 12, 30), category: "Entertainment/Leisure",
                    notes: "Diningout related transaction"),
        Transaction(name: "Utilities", amount: 131.56, type: .expense,
                    date: makeDate(2025, 12, 28), category: "Utilities"),
        Transaction(name: "Groceries", amount: 207.32, type: .expense,
                    date: makeDate(2025, 12, 24), category: "Groceries"),
        Transaction(name: "Monthly Paycheck", amount: 3020.67, type: .income,
                    date: makeDate(2025, 9, 30), category: "Salary",
                    notes: "Paycheck came in from work. Salary for the month."),
        Transaction(name: "October Paycheck", amount: 3020.67, type: .income,
                    date: makeDate(2026, 10, 31), category: "Salary"),
        Transaction(name: "Logo Design Gig", amount: 450.00, type: .income,
                    date: makeDate(2026, 10, 15), category: "Freelance",
                    notes: "Logo for a local bakery."),
        Transaction(name: "Gas", amount: 48.75, type: .expense,
                    date: makeDate(2026, 10, 20), category: "Transportation"),
        Transaction(name: "Phone Bill", amount: 65.00, type: .expense,
                    date: makeDate(2026, 10, 5), category: "Utilities")
    ]
}
