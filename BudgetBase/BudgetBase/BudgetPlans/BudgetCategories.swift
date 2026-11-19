//
//  BudgetCategories.swift
//  BudgetBase
//
//  Created by Andrew Lee on 11/17/26.
//

import Foundation

// default values for Zero-Based before user input
let DEFAULT_LIVING_ESSENTIALS: Double = 1000
let DEFAULT_FINANCIAL_OBLIGATIONS: Double = 1000
let DEFAULT_TRANSPORTATION: Double = 1000
let DEFAULT_LIFESTYLE: Double = 1000
let DEFAULT_GROWTH_HEALTH: Double = 1000
let DEFAULT_SAVINGS_INVESTMENTS: Double = 1000

enum SpendingGroup: String, CaseIterable, Identifiable {
    case needs = "Needs"
    case wants = "Wants"
    case savings = "Savings"
    
    var id: String { rawValue }
    
    var share: Double {
        switch self {
        case .needs: 0.5
        case .wants: 0.3
        case .savings: 0.2
        }
    }
    
    var categories: Set<String> {
        switch self {
            // fill out after deciding what is what in transaction types
        case .needs: []
        case .wants: []
        case .savings: []
        }
    }
}

enum ZeroBasedCategory: String, CaseIterable, Identifiable {
    case livingEssenetials = "Living Essentials"
    case financialObligations = "Financial Obligations"
    case transportation = "Transportation"
    case lifestyle = "Lifestyle"
    case growthAndHealth = "Growth & Health"
    case savingsAndInvestments = "Savings & Investments"
    
    var id: String { rawValue }
    
    var categories: Set<String> {
        switch self {
            // fill out based on transaction types
        case .livingEssenetials: []
        case .financialObligations: []
        case .transportation: []
        case .lifestyle: []
        case .growthAndHealth: []
        case .savingsAndInvestments: []
        }
    }
    
    var defaultAmount: Double {
        switch self {
        case .livingEssenetials: DEFAULT_LIVING_ESSENTIALS
        case .financialObligations: DEFAULT_FINANCIAL_OBLIGATIONS
        case .transportation: DEFAULT_TRANPORTATION
        case .lifestyle: DEFAULT_LIFESTYLE
        case .growthAndHealth: DEFAULT_GROWTH_HEALTH
        case .savingsAndInvestments: DEFAULT_SAVINGS_INVESTMENTS
        }
    }
}
    
enum TimeRange: String, CaseIterable, Identifiable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
    
    var id: String { rawValue }
    
    var periodName: String {
        switch self {
        case .week: "Weekly"
        case .month: "Monthly"
        case .year: "Yearly"
        }
    }
    
    var component: Calendar.Component {
        switch self {
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        }
    }
    
    var periodCount: Int {
        switch self {
        case .week: 8
        case .month: 6
        case .year: 5
        }
    }
}

enum ChartStyle: String, CaseIterable, Identifiable {
    case pie = "Pie"
    case bar = "Bar"
    
    var id: String { rawValue }
}
