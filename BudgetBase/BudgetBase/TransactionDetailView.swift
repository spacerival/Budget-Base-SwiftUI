//
//  TransactionDetailView.swift
//  BudgetBase
//
//  Created by Chantal Le on 11/19/26.
//

import Foundation
import SwiftUI

// Transaction Detail View: shows one transaction in full. Opened from the History list.
struct TransactionDetailView: View {
    // A plain `let`: this screen only DISPLAYS a transaction, it never changes it.
    let transaction: Transaction

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            // Title
            Text(transaction.name)
                .font(.title2)
                .bold()
                .foregroundStyle(Color.brandBlue)

            // Amount row: label on the left, amount pushed to the right
            HStack {
                Text("Amount")
                Spacer()
                Text(transaction.signedAmountText)
                    .foregroundStyle(transaction.type.color)
            }
            .font(.title3)

            Divider()

            // Label + value rows
            DetailRow(label: "Type",
                      value: transaction.type.rawValue,
                      valueColor: transaction.type.color)
            DetailRow(label: "Date",
                      value: transaction.date.formatted(date: .long, time: .omitted))
            DetailRow(label: "Category",
                      value: transaction.category)

            // Notes only appear if there are any
            if !transaction.notes.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes")
                        .foregroundStyle(.secondary)
                    Text(transaction.notes)
                        .font(.subheadline)
                }
                .padding(.top, 8)
            }

            Spacer()   // pushes everything to the top of the screen
        }
        .padding()
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// A small reusable view: gray label, then the value.
struct DetailRow: View {
    let label: String
    let value: String
    var valueColor: Color = .primary

    var body: some View {
        HStack(spacing: 6) {
            Text(label)
                .foregroundStyle(.secondary)
            Text(value)
                .foregroundStyle(valueColor)
        }
    }
}

#Preview {
    NavigationStack {
        TransactionDetailView(transaction: Transaction.samples[2])
    }
}
