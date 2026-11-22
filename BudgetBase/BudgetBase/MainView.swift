//
//  MainView.swift
//  BudgetBase
//
//  Created by Chantal Le on 11/12/26.
//

import Foundation
import SwiftUI

// Main View: the welcome screen with the app title and Start button.
struct MainView: View {
    @ObservedObject var store: TransactionStore

    // false = show the welcome screen, true = show the tab bar app.
    @State private var hasStarted = false

    var body: some View {
        if hasStarted {
            MainTabView(store: store)
        } else {
            welcomeScreen
        }
    }

    private var welcomeScreen: some View {
        VStack(spacing: 6) {
            Text("Budget Base")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(Color.brandBlue)

            Text("Saving money made simple")
                .font(.subheadline)
                .foregroundStyle(Color.brandBlue)

            Spacer()   // pushes the title up and the button down

            Button {
                withAnimation {
                    hasStarted = true
                }
            } label: {
                Text("Start")
                    .font(.title3)
                    .padding(.horizontal, 24)   // makes the button wider
                    .padding(.vertical, 10)     // makes the button taller
            }
            .buttonStyle(.borderedProminent)
            .buttonBorderShape(.roundedRectangle(radius: 14))   // rounded rectangle, not a pill
        }
        .padding(.top, 60)
        .padding(.bottom, 40)
    }
}

#Preview {
    MainView(store: TransactionStore(inMemory: true))
}
