//
//  GroupedListSwiftUICoreDataApp.swift
//  GroupedListSwiftUICoreData
//
//  Created by Gene Bogdanovich on 16.04.21.
//

import SwiftUI

@main
struct GroupedListSwiftUICoreDataApp: App {
    @Environment(\.scenePhase) private var scenePhase
    private let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { (newPhase) in
            switch newPhase {
            case .active:
                #if DEBUG
                UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
                #endif
            case .inactive:
                break
            case .background:
                try! persistenceController.container.viewContext.save()
            @unknown default:
                break
            }
        }
    }
}
