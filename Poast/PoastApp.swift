//
//  PoastApp.swift
//  Poast
//
//  Created by Christopher Head on 7/29/23.
//

import SwiftUI

@main
struct PoastApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
