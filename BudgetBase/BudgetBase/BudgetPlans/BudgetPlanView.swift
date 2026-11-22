//
//  BudgetPlanView.swift
//  BudgetBase
//
//  Created by Andrew Lee on 11/19/26.
//

import Foundation
import SwiftUI

enum BudgetPlan: String, CaseIterable, Identifiable {
    case fiftyThirtyTwenty = "50/30/20"
    case zeroBased = "Zero-Based"
    case payYourselfFirst = "Pay Yourself First"

    static let storageKey = "savedBudgetPlan"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .fiftyThirtyTwenty: "50/30/20"
        case .zeroBased: "Zero-Based"
        case .payYourselfFirst: "Pay-Yourself-First"
        }
    }

    var symbol: String {
        switch self {
        case .fiftyThirtyTwenty: "chart.pie.fill"
        case .zeroBased: "scalemass.fill"
        case .payYourselfFirst: "dollarsign.circle.fill"
        }
    }

    var summary: String {
        switch self {
        case .fiftyThirtyTwenty:
            "The 50/30/20 plan is the most popular budget plan. 50% of your net income goes to needs, your essential expenses. 30% of your net income goes to your wants, your non-essential expenses. 20% of your net income goes to your financial goals, whether it is adding to your savings, paying off debts, or investing your money."
        case .zeroBased:
            "The Zero-Based budget plan is for those who want to know exactly where their money is going. Every cent of your income is categorized into groups, such as groceries, clothes, savings, loan repayment, etc. It is the most detailed approach to budgeting."
        case .payYourselfFirst:
            "The Pay-Yourself-First method is the simplest approach to budgeting. It prioritizes your savings before expenses. When you receive your monthly income, you set aside a certain amount first. After you deposit into your savings, you pay for your essential, non-negotiable expenses next, followed by non-essential ones."
        }
    }
}

struct BudgetPlanView: View {
    @ObservedObject var store: TransactionStore
    @ObservedObject var settings: BudgetSettings

    @AppStorage(BudgetPlan.storageKey) private var savedPlan: BudgetPlan?
    @State private var selectedPlan = BudgetPlan(rawValue: UserDefaults.standard.string(forKey: BudgetPlan.storageKey) ?? "") ?? .fiftyThirtyTwenty
    @State private var isChangingPlan = false
    @FocusState private var focusedField: String?

    private var currentPlan: BudgetPlan? {
        isChangingPlan ? nil : savedPlan
    }

    private var monthlyIncome: Double {
        store.incomeThisMonth()
    }

    var body: some View {
        ScrollView {
            Group {
                switch currentPlan {
                case .fiftyThirtyTwenty:
                    FiftyThirtyTwentyPlanView(store: store, changePlan: changePlan)
                case .zeroBased:
                    ZeroBasedPlanView(store: store, settings: settings, changePlan: changePlan)
                case .payYourselfFirst:
                    PayYourselfFirstPlanView(store: store, settings: settings, changePlan: changePlan)
                case nil:
                    planSetup
                }
            }
            .frame(maxWidth: 700)
            .padding(16)
            .frame(maxWidth: .infinity)
        }
        .id(currentPlan)
        .scrollDismissesKeyboard(.interactively)
        .background(Color(uiColor: .secondarySystemBackground))
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()

                Button("Done") {
                    focusedField = nil
                }
            }
        }
    }

    private var planSetup: some View {
        VStack(spacing: 16) {
            Text("Budget Plans")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity)

            Text("Select the budget plan that fits your needs")
                .font(.headline)
                .multilineTextAlignment(.center)

            planDetailsSection

            if selectedPlan == .zeroBased {
                zeroBasedSection
            }

            if selectedPlan == .payYourselfFirst {
                payYourselfFirstSection
            }

            Button {
                choose(selectedPlan)
            } label: {
                Text("View")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)

            learnSection
        }
    }

    private var planDetailsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                Text("Budget Plan")
                    .font(.subheadline)
                    .frame(width: 120, alignment: .leading)

                Menu {
                    Picker("Budget Plan", selection: $selectedPlan) {
                        ForEach(BudgetPlan.allCases) { plan in
                            Text(plan.displayName).tag(plan)
                        }
                    }
                } label: {
                    Text(selectedPlan.displayName)
                        .font(.footnote)
                        .frame(maxWidth: .infinity)
                        .frame(height: 34)
                        .background(Color(uiColor: .secondarySystemBackground), in: .rect(cornerRadius: 8))
                }
            }

            HStack(spacing: 12) {
                Text("Monthly Income")
                    .font(.subheadline)
                    .frame(width: 120, alignment: .leading)

                Text(monthlyIncome.formatted(.currency(code: "USD")))
                    .font(.subheadline.bold())
            }

            Text("From this month's income transactions")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 12))
    }

    private var zeroBasedSection: some View {
        let unallocated = monthlyIncome - settings.totalAllocated

        return VStack(alignment: .leading, spacing: 12) {
            Text("Assign a planned budget for each category below")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            ForEach(ZeroBasedCategory.allCases) { category in
                HStack(spacing: 12) {
                    Text(category.rawValue)
                        .font(.subheadline)

                    Spacer()

                    NumberField(title: category.rawValue, value: Binding(
                        get: { settings.allocation(for: category) },
                        set: { settings.setAllocation($0, for: category) }
                    ))
                    .font(.subheadline)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: category.rawValue)
                    .frame(width: 100)
                }
            }

            Text("Total Allocated: \(settings.totalAllocated.formatted(.currency(code: "USD")))")
                .font(.subheadline.bold())

            Text("Unallocated: \(unallocated.formatted(.currency(code: "USD")))")
                .font(.subheadline.bold())
                .foregroundStyle(unallocated < 0 ? Color.red : Color.primary)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 12))
    }

    private var payYourselfFirstSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Set your savings goal before budgeting expenses")
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Text("Choose a percentage-based or a set block savings budget")
                .font(.footnote)
                .foregroundStyle(.secondary)

            Toggle(isOn: $settings.isBlockSavings) {
                Text(settings.isBlockSavings ? "Block Savings" : "Percentage Savings")
                    .font(.subheadline.bold())
            }

            HStack(spacing: 12) {
                Text(settings.isBlockSavings ? "How much do you aim to put into savings this month? ($)" : "How much do you aim to put into savings this month? (%)")
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                NumberField(title: "Savings Goal", value: $settings.savingsGoal)
                    .id(settings.isBlockSavings)
                    .font(.subheadline)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: "savingsGoal")
                    .frame(width: 80)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 12))
    }

    private var learnSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Learn what plan is right for you")
                .font(.headline)

            ForEach(BudgetPlan.allCases) { plan in
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Image(systemName: plan.symbol)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 24, height: 24)

                        Text(plan.displayName)
                            .font(.subheadline.bold())
                    }

                    Text(plan.summary)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 12))
    }

    private func choose(_ plan: BudgetPlan) {
        selectedPlan = plan
        savedPlan = plan
        isChangingPlan = false
    }

    private func changePlan() {
        isChangingPlan = true
    }
}

private struct NumberField: View {
    let title: String
    @Binding var value: Double
    @State private var text = ""

    var body: some View {
        TextField(title, text: $text)
            .onAppear {
                text = value.formatted(.number.grouping(.never))
            }
            .onChange(of: text) {
                value = Double(text) ?? 0
            }
    }
}

#Preview {
    BudgetPlanView(store: TransactionStore(inMemory: true), settings: BudgetSettings())
}
