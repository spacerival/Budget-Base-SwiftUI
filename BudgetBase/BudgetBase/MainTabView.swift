//
//  MainTabView.swift
//  BudgetBase
//
//  Created by Chantal Le on 11/12/26.
//

import Foundation
import SwiftUI

// The tab bar container (replaces the Tab Bar Controller in the storyboard).
// SHARED FILE: every tab is a placeholder for now. Whoever finishes a screen
// replaces its placeholder line, e.g. Text("History") -> TransactionHistoryView(store: store)
struct MainTabView: View {
    @ObservedObject var store: TransactionStore

    var body: some View {
        TabView {
            Tab("Overview", systemImage: "chart.pie") {
                Text("Overview (coming soon)")
            }
            Tab("Budget Plan", systemImage: "chart.line.uptrend.xyaxis") {
                Text("Budget Plan (coming soon)")
            }
            Tab("Add", systemImage: "plus.circle") {
                Text("Add Transaction (coming soon)")
            }
            Tab("History", systemImage: "clipboard") {
                Text("History (coming soon)")
            }
        }
    }
}

#Preview {
    MainTabView(store: TransactionStore(inMemory: true))
}
