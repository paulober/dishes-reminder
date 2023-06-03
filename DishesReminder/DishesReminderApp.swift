//
//  DishesReminderApp.swift
//  dishes reminder
//
//  Created by Paul on 28.05.23.
//

import SwiftUI

@main
struct DishesReminderApp: App {
    @StateObject
    private var store = DishesStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView(dishes: $store.dishes, loadAction: { Task {
                do {
                    try await store.load()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }}) {
                Task {
                    do {
                        try await store.save(dishes: store.dishes)
                    } catch {
                        fatalError(error.localizedDescription)
                    }
                }
            }
            .task {
                do {
                    try await store.load()
                } catch {
                    fatalError(error.localizedDescription)
                }
            }
        }
    }
}
