//
//  CoreDataAppApp.swift
//  CoreDataApp
//
//  Created by Kaio Guanais on 2020-09-03.
//

import SwiftUI
import CoreData

@main
struct CoreDataAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentContainer.viewContext)
                
        }
    }
}

// Core Data container
var persistentContainer: NSPersistentContainer = {
    let container = NSPersistentContainer(name: "CoreData")
    container.loadPersistentStores { description, error in
        if let error = error {
            fatalError("Unresolved Error \(error), \(error.localizedDescription)")
        }
    }
    return container
}()

func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
        do {
            try context.save()
        } catch {
            fatalError("Unresolved Error \(error), \(error.localizedDescription)")
        }
    }
}

struct CoreDataApp_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
