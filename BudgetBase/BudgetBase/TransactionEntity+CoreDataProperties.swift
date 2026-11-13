//
//  TransactionEntity+CoreDataProperties.swift
//  BudgetBase
//
//  Created by Chantal Le on 11/12/26.
//
//

public import Foundation
public import CoreData


public typealias TransactionEntityCoreDataPropertiesSet = NSSet

extension TransactionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TransactionEntity> {
        return NSFetchRequest<TransactionEntity>(entityName: "TransactionEntity")
    }

    @NSManaged nonisolated public var id: UUID?
    @NSManaged nonisolated public var name: String?
    @NSManaged nonisolated public var amount: Double
    @NSManaged nonisolated public var transactionType: String?
    @NSManaged nonisolated public var date: Date?
    @NSManaged nonisolated public var category: String?
    @NSManaged nonisolated public var notes: String?

}

extension TransactionEntity : Identifiable {

}
