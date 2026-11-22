//
//  TransactionStore.swift
//  BudgetBase
//
//  Created by Chantal Le on 11/12/26.
//

import Foundation
import SwiftUI
import CoreData
import Combine

// The shared list of transactions, now backed by a Core Data (SQLite) database.
// Screens still just call `store.transactions`, `store.add(...)` and `store.delete(...)`.
class TransactionStore: ObservableObject {
    // What the screens display. Refreshed from the database after every change.
    @Published var transactions: [Transaction] = []

    // The connection to the database file.
    private let container: NSPersistentContainer

    // The "scratchpad" where you create, change and delete objects before saving.
    private var context: NSManagedObjectContext {
        container.viewContext
    }

    // A flag (stored in UserDefaults) remembering that starting data was already added.
    private static let seededKey = "hasSeededSampleData"

    // inMemory: true = a throwaway database that is never written to disk (for #Preview).
    init(inMemory: Bool = false) {
        // Must match the data model file's name: BudgetBase.xcdatamodeld
        container = NSPersistentContainer(name: "BudgetBase")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { _, error in
            if let error {
                fatalError("Could not load the database: \(error)")
            }
        }

        seedIfNeeded(inMemory: inMemory)
        fetchTransactions()
    }

    // Read

    // Load every saved transaction, newest first.
    func fetchTransactions() {
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            let entities = try context.fetch(request)
            transactions = entities.map { Transaction(entity: $0) }
        } catch {
            print("Could not fetch transactions: \(error)")
        }
    }

    // Create

    func add(_ transaction: Transaction) {
        insertEntity(for: transaction)
        saveContext()
        fetchTransactions()
    }

    // Delete

    func delete(_ transaction: Transaction) {
        let request = NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
        request.predicate = NSPredicate(format: "id == %@", transaction.id as CVarArg)

        do {
            let matches = try context.fetch(request)
            for entity in matches {
                context.delete(entity)
            }
            saveContext()
            fetchTransactions()
        } catch {
            print("Could not delete transaction: \(error)")
        }
    }

    // Helpers

    // Copy a Transaction struct into a new database object.
    private func insertEntity(for transaction: Transaction) {
        let entity = TransactionEntity(context: context)
        entity.id = transaction.id
        entity.name = transaction.name
        entity.amount = transaction.amount
        entity.transactionType = transaction.type.rawValue
        entity.date = transaction.date
        entity.category = transaction.category
        entity.notes = transaction.notes
    }

    // Write any pending changes to the database file.
    private func saveContext() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Could not save: \(error)")
        }
    }

    // Add the starting transactions once: the first time the app ever runs.
    private func seedIfNeeded(inMemory: Bool) {
        let defaults = UserDefaults.standard
        let alreadySeeded = defaults.bool(forKey: Self.seededKey)

        // Previews always get the samples; the real app only gets them once.
        guard inMemory || !alreadySeeded else { return }

        for transaction in Transaction.samples {
            insertEntity(for: transaction)
        }
        saveContext()

        if !inMemory {
            defaults.set(true, forKey: Self.seededKey)
        }
    }
}

// Database object -> Transaction struct

extension Transaction {
    init(entity: TransactionEntity) {
        self.init(
            id: entity.id ?? UUID(),
            name: entity.name ?? "",
            amount: entity.amount,
            type: TransactionType(rawValue: entity.transactionType ?? "") ?? .expense,
            date: entity.date ?? Date(),
            category: entity.category ?? "",
            notes: entity.notes ?? ""
        )
    }
}
