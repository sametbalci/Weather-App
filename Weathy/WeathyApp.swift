//
//  WeathyApp.swift
//  Weathy
//
//  Created by BUSINESS ZAMED on 7.07.2024.
//

import SwiftUI

@main
struct WeathyApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
