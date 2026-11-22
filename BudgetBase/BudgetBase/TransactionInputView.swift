//
//  TransactionInputView.swift
//  BudgetBase
//
//  Created by Chantal Le on 11/19/26.
//

import Foundation
import SwiftUI

// Transaction Input View: the form for adding a new income or expense.
struct TransactionInputView: View {
    @ObservedObject var store: TransactionStore

    // One @State variable per thing the user can type or pick.
    @State private var type: TransactionType = .income
    @State private var amountText = ""
    @State private var date = Date()
    @State private var category = ""
    @State private var descriptionText = ""
    @State private var notes = ""
    @State private var showSavedAlert = false

    // Turns the typed text into a number. nil if it isn't a valid number.
    private var amount: Double? {
        Double(amountText)
    }

    // The Add button only turns on when the required fields make sense.
    private var isFormValid: Bool {
        guard let amount, amount > 0 else { return false }
        return !category.isEmpty
            && !descriptionText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // 1. Header
                VStack(spacing: 4) {
                    Text("Add Transaction")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.brandBlue)
                    Text("Record your income or expense")
                }
                .frame(maxWidth: .infinity)

                // 2. Income / Expense toggle
                Picker("Type", selection: $type) {
                    ForEach(TransactionType.allCases) { option in
                        Text(option.rawValue).tag(option)
                    }
                }
                .pickerStyle(.segmented)

                // 3. Amount and Date, side by side
                HStack(alignment: .top, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Amount ($)")
                        TextField("0.00", text: $amountText)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(.roundedBorder)
                    }
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Date")
                        DatePicker("Date", selection: $date, displayedComponents: .date)
                            .labelsHidden()
                    }
                }

                // 4. Category dropdown
                VStack(alignment: .leading, spacing: 6) {
                    Text("Category")
                    Picker("Category", selection: $category) {
                        Text("Select a category").tag("")
                        ForEach(type.categories, id: \.self) { name in
                            Text(name).tag(name)
                        }
                    }
                    .pickerStyle(.menu)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .clipShape(Capsule())
                }

                // 5. Description
                VStack(alignment: .leading, spacing: 6) {
                    Text("Description")
                    TextField("Brief description of the transaction", text: $descriptionText)
                        .textFieldStyle(.roundedBorder)
                }

                // 6. Notes (multi-line)
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes (Optional)")
                    TextEditor(text: $notes)
                        .frame(height: 100)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4))
                        )
                }

                // 7. Add button
                Button {
                    addTransaction()
                } label: {
                    Text("Add Transaction")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .disabled(!isFormValid)
            }
            .padding()
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: type) {
            // Income and Expense have different category lists,
            // so clear the old pick when the type flips.
            category = ""
        }
        .alert("Transaction added", isPresented: $showSavedAlert) {
            Button("OK", role: .cancel) { }
        }
    }

    // Actions

    private func addTransaction() {
        guard let amount else { return }

        let newTransaction = Transaction(
            name: descriptionText.trimmingCharacters(in: .whitespaces),
            amount: amount,
            type: type,
            date: date,
            category: category,
            notes: notes
        )
        store.add(newTransaction)
        clearForm()
        showSavedAlert = true
    }

    private func clearForm() {
        amountText = ""
        date = Date()
        category = ""
        descriptionText = ""
        notes = ""
    }
}

#Preview {
    TransactionInputView(store: TransactionStore(inMemory: true))
}
