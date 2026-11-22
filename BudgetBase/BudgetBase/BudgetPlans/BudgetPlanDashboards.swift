//
//  BudgetPlanDashboards.swift
//  BudgetBase
//
//  Created by Andrew Lee on 11/19/26.
//

import Foundation
import Charts
import SwiftUI

extension SpendingGroup {
    var tint: Color {
        switch self {
        case .needs: .indigo
        case .wants: .green
        case .savings: .orange
        }
    }
}

struct SavingsPoint: Identifiable {
    let date: Date
    let total: Double
    
    var id: Date { date }
}

struct CurrentPlanHeader: View {
    let plan: BudgetPlan
    let changePlan: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Budget Plans")
                .font(.largeTitle)
                .bold()
                .frame(maxWidth: .infinity)
            
            HStack(spacing: 12) {
                Text("Your Current Budget Plan: \(plan.displayName)")
                    .font(.subheadline.bold())
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Button("Change Plan", action: changePlan)
                    .buttonStyle(.bordered)
            }
        }
    }
}

struct FiftyThirtyTwentyPlanView: View {
    @ObservedObject var store: TransactionStore
    let changePlan: () -> Void
    
    private var monthExpenses: [Transaction] {
        store.expensesThisMonth()
    }
    
    private var monthlyIncome: Double {
        store.incomeThisMonth()
    }
    
    private func spent(_ group: SpendingGroup) -> Double {
        monthExpenses.inCategories(group.categories).total
    }
    
    private func budget(_ group: SpendingGroup) -> Double {
        monthlyIncome * group.share
    }
    
    var body: some View {
        let months = store.periods(for: .month)
        
        VStack(spacing: 16) {
            CurrentPlanHeader(plan: .fiftyThirtyTwenty, changePlan: changePlan)
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Current Budget Breakdown")
                    .font(.headline)
                
                HStack(spacing: 8) {
                    ForEach(SpendingGroup.allCases) { group in
                        Label {
                            Text(group.rawValue)
                        } icon: {
                            Circle()
                                .fill(group.tint)
                                .frame(width: 8, height: 8)
                        }
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                    }
                }

                if monthExpenses.isEmpty {
                    ContentUnavailableView("No spending this month", systemImage: "chart.pie.fill")
                        .frame(height: 160)
                } else {
                    Chart(SpendingGroup.allCases) { group in
                        SectorMark(angle: .value("Spent", spent(group)), innerRadius: .ratio(0.5), angularInset: 1)
                            .foregroundStyle(group.tint)
                    }
                    .frame(height: 160)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 12) {
                Text("Monthly Breakdown")
                    .font(.headline)

                if months.allSatisfy({ $0.expenses == 0 }) {
                    ContentUnavailableView("No spending in the last 6 months", systemImage: "chart.bar.fill")
                        .frame(height: 160)
                } else {
                    Chart {
                        ForEach(months) { month in
                            ForEach(SpendingGroup.allCases) { group in
                                BarMark(
                                    x: .value("Month", month.start, unit: .month),
                                    y: .value("Spent", month.transactions.expenses.inCategories(group.categories).total)
                                )
                                .foregroundStyle(by: .value("Group", group.rawValue))
                            }
                        }
                    }
                    .chartForegroundStyleScale(domain: SpendingGroup.allCases.map(\.rawValue), range: SpendingGroup.allCases.map(\.tint))
                    .chartLegend(.hidden)
                    .frame(height: 160)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 16) {
                Text("Budget Progress")
                    .font(.headline)

                ForEach(SpendingGroup.allCases) { group in
                    let fraction = budget(group) > 0 ? spent(group) / budget(group) : 0

                    VStack(alignment: .leading, spacing: 8) {
                        HStack(spacing: 8) {
                            Text(group.rawValue)
                                .font(.subheadline.bold())

                            Text("\(Int((fraction * 100).rounded()))%")
                                .font(.subheadline.bold())
                                .foregroundStyle(fraction > 1 ? Color.red : Color.indigo)

                            Spacer()

                            Text("\(spent(group).formatted(.currency(code: "USD"))) of \(budget(group).formatted(.currency(code: "USD")))")
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }

                        ProgressView(value: min(fraction, 1))
                            .tint(fraction > 1 ? Color.red : group.tint)
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 12))
        }
    }
}

struct ZeroBasedPlanView: View {
    @ObservedObject var store: TransactionStore
    @ObservedObject var settings: BudgetSettings
    let changePlan: () -> Void

    @State private var incomeRange = TimeRange.month
    @State private var breakdownStyle = ChartStyle.bar

    private var monthExpenses: [Transaction] {
        store.expensesThisMonth()
    }

    private func actual(_ category: ZeroBasedCategory) -> Double {
        monthExpenses.inCategories(category.categories).total
    }

    var body: some View {
        let periods = store.periods(for: incomeRange)
        let actuals = ZeroBasedCategory.allCases.map { CategoryTotal(name: $0.rawValue, amount: actual($0)) }
        let remaining = settings.totalAllocated - monthExpenses.total

        VStack(spacing: 16) {
            CurrentPlanHeader(plan: .zeroBased, changePlan: changePlan)

            VStack(alignment: .leading, spacing: 2) {
                Text("Zero-Based Budget Plan")
                    .font(.title3.bold())

                Text("Every dollar has a purpose")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            VStack(alignment: .leading, spacing: 12) {
                Text("Income vs. Expenses Over Time")
                    .font(.headline)

                Picker("Range", selection: $incomeRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.rawValue).tag(range)
                    }
                }
                .pickerStyle(.segmented)

                if periods.allSatisfy({ $0.income == 0 && $0.expenses == 0 }) {
                    ContentUnavailableView("No transactions in this range", systemImage: "chart.line.uptrend.xyaxis")
                        .frame(height: 160)
                } else {
                    Chart {
                        ForEach(periods) { period in
                            LineMark(x: .value("Period", period.start, unit: incomeRange.component), y: .value("Amount", period.income))
                                .foregroundStyle(by: .value("Type", "Income"))
                            LineMark(x: .value("Period", period.start, unit: incomeRange.component), y: .value("Amount", period.expenses))
                                .foregroundStyle(by: .value("Type", "Expenses"))
                        }
                    }
                    .chartForegroundStyleScale(["Income": Color.green, "Expenses": Color.red])
                    .frame(height: 160)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 12) {
                HStack(spacing: 8) {
                    Text("Category Breakdown")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    Picker("Chart Style", selection: $breakdownStyle) {
                        ForEach([ChartStyle.bar, ChartStyle.pie]) { style in
                            Text(style.rawValue).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                    .frame(width: 100)
                }

                if monthExpenses.isEmpty {
                    ContentUnavailableView("No spending this month", systemImage: "chart.bar.xaxis")
                        .frame(height: 160)
                } else {
                    Chart(actuals) { item in
                        if breakdownStyle == .bar {
                            BarMark(x: .value("Spent", item.amount), y: .value("Category", item.name))
                                .foregroundStyle(by: .value("Category", item.name))
                        } else {
                            SectorMark(angle: .value("Spent", item.amount), angularInset: 1)
                                .foregroundStyle(by: .value("Category", item.name))
                        }
                    }
                    .chartLegend(breakdownStyle == .pie ? .visible : .hidden)
                    .frame(height: 160)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 12))

            HStack(spacing: 12) {
                summaryCard("Total Budget", value: settings.totalAllocated, color: .primary)
                summaryCard("Total Expenses", value: monthExpenses.total, color: .primary)
                summaryCard("Remaining", value: remaining, color: remaining < 0 ? .red : .green)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Category Budget Tracker")
                    .font(.headline)

                HStack(spacing: 8) {
                    Text("Category")
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("Goal")
                        .frame(width: 64, alignment: .trailing)
                    Text("Actual")
                        .frame(width: 64, alignment: .trailing)
                    Text("Difference")
                        .frame(width: 74, alignment: .trailing)
                }
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.secondary)

                ForEach(ZeroBasedCategory.allCases) { category in
                    let goal = settings.allocation(for: category)
                    let difference = goal - actual(category)
                    let isOver = difference < 0

                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(category.rawValue)
                                .font(.footnote.bold())

                            Text(isOver ? "OVER BUDGET" : "ON TRACK")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(isOver ? Color.red : Color.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background((isOver ? Color.red : Color.green).opacity(0.15), in: .rect(cornerRadius: 9))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)

                        Text(goal.formatted(.currency(code: "USD")))
                            .frame(width: 64, alignment: .trailing)

                        Text(actual(category).formatted(.currency(code: "USD")))
                            .frame(width: 64, alignment: .trailing)

                        // Always shows a sign: "+$12.00" or "-$12.00".
                        Text(difference.formatted(.currency(code: "USD").sign(strategy: .always())))
                            .foregroundStyle(isOver ? Color.red : Color.green)
                            .frame(width: 74, alignment: .trailing)
                    }
                    .font(.footnote)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 12))
        }
    }

    private func summaryCard(_ title: String, value: Double, color: Color) -> some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.footnote)
                .foregroundStyle(.secondary)

            Text(value.formatted(.currency(code: "USD")))
                .font(.title3.bold())
                .foregroundStyle(color)
                .minimumScaleFactor(0.6)
                .lineLimit(1)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 12))
    }
}

struct PayYourselfFirstPlanView: View {
    @ObservedObject var store: TransactionStore
    @ObservedObject var settings: BudgetSettings
    let changePlan: () -> Void

    @State private var growthRange = TimeRange.week

    private var monthlyIncome: Double {
        store.incomeThisMonth()
    }

    private var allSavings: [Transaction] {
        store.expenses.inCategories(SpendingGroup.savings.categories)
    }

    private var savedThisMonth: Double {
        store.expensesThisMonth().inCategories(SpendingGroup.savings.categories).total
    }

    private var goalText: String {
        let goal = settings.monthlySavingsGoal(income: monthlyIncome).formatted(.currency(code: "USD"))
        if settings.isBlockSavings {
            return "Monthly Goal: \(goal)"
        }
        return "Monthly Goal: \(settings.savingsGoal.formatted(.number.grouping(.never)))% (\(goal))"
    }

    // A percentage goal with no income this month is $0, so explain why instead of saying "set a goal".
    private var noGoalMessage: String {
        if !settings.isBlockSavings && monthlyIncome == 0 && settings.savingsGoal > 0 {
            return "No income recorded this month"
        }
        return "Set a savings goal in Change Plan"
    }

    // Running total of savings at the end of each period.
    private func growthPoints(_ periods: [Period]) -> [SavingsPoint] {
        guard let first = periods.first else { return [] }
        var running = allSavings.filter { $0.date < first.start }.total
        return periods.map { period in
            running += period.savings
            return SavingsPoint(date: period.start, total: running)
        }
    }

    // Change from the previous period to the latest one.
    private func growthTrend(_ periods: [Period]) -> String {
        guard periods.count >= 2 else { return "—" }
        let previous = periods[periods.count - 2].savings
        let latest = periods[periods.count - 1].savings
        guard previous > 0 else { return latest > 0 ? "New" : "0%" }
        let change = (latest - previous) / previous * 100
        return (change > 0 ? "+" : "") + "\(Int(change.rounded()))%"
    }

    var body: some View {
        let goal = settings.monthlySavingsGoal(income: monthlyIncome)
        let periods = store.periods(for: growthRange)
        let points = growthPoints(periods)
        let averagePerPeriod = periods.isEmpty ? 0 : periods.map(\.savings).reduce(0, +) / Double(periods.count)

        VStack(spacing: 16) {
            CurrentPlanHeader(plan: .payYourselfFirst, changePlan: changePlan)

            VStack(alignment: .leading, spacing: 12) {
                Text("Your Savings Goal Progress")
                    .font(.headline)

                if goal <= 0 {
                    ContentUnavailableView(noGoalMessage, systemImage: "chart.pie.fill")
                        .frame(height: 160)
                } else {
                    Chart {
                        SectorMark(angle: .value("Saved", min(savedThisMonth, goal)), innerRadius: .ratio(0.65))
                            .foregroundStyle(Color.green)
                        SectorMark(angle: .value("Remaining", max(goal - savedThisMonth, 0)), innerRadius: .ratio(0.65))
                            .foregroundStyle(Color(uiColor: .systemGray5))
                    }
                    .frame(height: 160)
                    .overlay {
                        Text("\(Int((min(savedThisMonth / goal, 1) * 100).rounded()))%")
                            .font(.title3.bold())
                    }
                }

                Text(goalText)
                    .font(.subheadline)

                Text("Total Saved This Month: \(savedThisMonth.formatted(.currency(code: "USD")))")
                    .font(.subheadline)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 12) {
                Text("Savings Growth Over Time")
                    .font(.headline)

                Picker("Range", selection: $growthRange) {
                    ForEach(TimeRange.allCases) { range in
                        Text(range.periodName).tag(range)
                    }
                }
                .pickerStyle(.segmented)

                if points.allSatisfy({ $0.total == 0 }) {
                    ContentUnavailableView("No savings yet", systemImage: "chart.line.uptrend.xyaxis")
                        .frame(height: 160)
                } else {
                    Chart(points) { point in
                        AreaMark(x: .value("Period", point.date, unit: growthRange.component), y: .value("Saved", point.total))
                            .foregroundStyle(Color.green.opacity(0.15))
                        LineMark(x: .value("Period", point.date, unit: growthRange.component), y: .value("Saved", point.total))
                            .foregroundStyle(Color.green)
                    }
                    .frame(height: 160)
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 12) {
                Text("Savings Summary")
                    .font(.headline)

                summaryRow("Total Saved", value: allSavings.total.formatted(.currency(code: "USD")), color: .green)
                summaryRow("Average per Period", value: averagePerPeriod.formatted(.currency(code: "USD")), color: .primary)
                summaryRow("Growth Trend", value: growthTrend(periods), color: .primary)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .systemBackground), in: .rect(cornerRadius: 12))
        }
    }

    private func summaryRow(_ title: String, value: String, color: Color) -> some View {
        HStack(spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)

            Spacer()

            Text(value)
                .font(.headline)
                .foregroundStyle(color)
        }
    }
}

#Preview("50/30/20") {
    ScrollView {
        FiftyThirtyTwentyPlanView(store: TransactionStore(inMemory: true), changePlan: {})
            .padding(16)
    }
    .background(Color(uiColor: .secondarySystemBackground))
}

#Preview("Zero-Based") {
    ScrollView {
        ZeroBasedPlanView(store: TransactionStore(inMemory: true), settings: BudgetSettings(), changePlan: {})
            .padding(16)
    }
    .background(Color(uiColor: .secondarySystemBackground))
}

#Preview("Pay Yourself First") {
    ScrollView {
        PayYourselfFirstPlanView(store: TransactionStore(inMemory: true), settings: BudgetSettings(), changePlan: {})
            .padding(16)
    }
    .background(Color(uiColor: .secondarySystemBackground))
}
