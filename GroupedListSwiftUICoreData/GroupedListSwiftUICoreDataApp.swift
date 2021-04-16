//
//  GroupedListSwiftUICoreDataApp.swift
//  GroupedListSwiftUICoreData
//
//  Created by Gene Bogdanovich on 16.04.21.
//

import SwiftUI

@main
struct GroupedListSwiftUICoreDataApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
