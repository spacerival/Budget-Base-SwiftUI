//
//  TransactionHistoryView.swift
//  BudgetBase
//
//  Created by Chantal Le on 11/19/26.
//

import Foundation
import SwiftUI

// Filter and Sort Choices

// Choices for the "Type" filter.
enum TypeFilter: String, CaseIterable, Identifiable {
    case all = "All Transactions"
    case income = "Income"
    case expense = "Expense"

    var id: String { rawValue }

    // Does this transaction pass the filter?
    func matches(_ transaction: Transaction) -> Bool {
        switch self {
        case .all:
            return true
        case .income:
            return transaction.type == .income
        case .expense:
            return transaction.type == .expense
        }
    }
}

// Choices for the "Sort By" menu.
enum HistorySortOrder: String, CaseIterable, Identifiable {
    case newestFirst = "Date (Newest First)"
    case oldestFirst = "Date (Oldest First)"

    var id: String { rawValue }
}

// Transaction History View

// The scrolling list of every transaction (replaces the UITableView screen).
struct TransactionHistoryView: View {
    @ObservedObject var store: TransactionStore

    @State private var typeFilter: TypeFilter = .all
    @State private var categoryFilter = ""          // "" means All Categories
    @State private var sortOrder: HistorySortOrder = .newestFirst

    // Every category that appears in at least one transaction, A to Z, no repeats.
    private var categoryOptions: [String] {
        let unique = Set(store.transactions.map { $0.category })
        return unique.sorted()
    }

    // The transactions to show: filtered first, then sorted.
    private var visibleTransactions: [Transaction] {
        let filtered = store.transactions.filter { transaction in
            typeFilter.matches(transaction)
                && (categoryFilter.isEmpty || transaction.category == categoryFilter)
        }
        return filtered.sorted { first, second in
            if sortOrder == .newestFirst {
                return first.date > second.date
            } else {
                return first.date < second.date
            }
        }
    }

    var body: some View {
        NavigationStack {
            List {
                // Section 1: the filter and sort menus
                Section {
                    Picker("Type", selection: $typeFilter) {
                        ForEach(TypeFilter.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                    Picker("Category", selection: $categoryFilter) {
                        Text("All Categories").tag("")
                        ForEach(categoryOptions, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    Picker("Sort By", selection: $sortOrder) {
                        ForEach(HistorySortOrder.allCases) { option in
                            Text(option.rawValue).tag(option)
                        }
                    }
                }

                // Section 2: one row per transaction
                Section {
                    if visibleTransactions.isEmpty {
                        Text("No transactions match these filters.")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(visibleTransactions) { transaction in
                            NavigationLink {
                                TransactionDetailView(transaction: transaction)
                            } label: {
                                TransactionRow(transaction: transaction)
                            }
                        }
                        .onDelete(perform: deleteTransactions)
                    }
                }
            }
            .listRowSpacing(10)
            .navigationTitle("My Transactions")
        }
    }

    // MARK: - Actions

    // Called when the user swipes a row left and taps Delete.
    private func deleteTransactions(at offsets: IndexSet) {
        // Look up the actual transactions FIRST, before anything is removed.
        let toDelete = offsets.map { visibleTransactions[$0] }
        for transaction in toDelete {
            store.delete(transaction)
        }
    }
}

// MARK: - One row in the list

// Reusable: your teammate's Overview "Recent Transactions" can use it too.
struct TransactionRow: View {
    let transaction: Transaction

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(transaction.name)
                    .bold()
                Text(transaction.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Text(transaction.signedAmountText)
                .bold()
                .foregroundStyle(transaction.type.color)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    TransactionHistoryView(store: TransactionStore(inMemory: true))
}
