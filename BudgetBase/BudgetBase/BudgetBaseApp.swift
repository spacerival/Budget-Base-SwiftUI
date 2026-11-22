//
//  BudgetBaseApp.swift
//  BudgetBase
//
//  Created by Chantal Le on 11/12/26.
//

import SwiftUI

// The entry point of the app. 
@main
struct BudgetBaseApp: App {
    // @StateObject = "this view CREATES and OWNS this object; keep it alive for the app's whole life."
    @StateObject private var store = TransactionStore()
    @StateObject private var settings = BudgetSettings()

    var body: some Scene {
        WindowGroup {
            MainView(store: store, settings: settings)
        }
    }
}
