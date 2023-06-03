//
//  DetailView.swift
//  DishesReminder
//
//  Created by Paul on 28.05.23.
//

import SwiftUI

struct DetailView: View {
    @Binding var dish: Dish
    @State private var editingDish = Dish.emptyDish
    
    @State private var isPresentingEditView = false

    var body: some View {
        List {
            Section(header: Text("Gericht Informationen")) {
                HStack {
                    Label("Name", systemImage: "character.cursor.ibeam")
                    Spacer()
                    Text(dish.name)
                }
                .accessibilityElement(children: .combine)
                HStack {
                    Label("Erstellt am", systemImage: "calendar.badge.plus")
                    Spacer()
                    Text(dish.created.formatted())
                }
                .accessibilityElement(children: .combine)
                HStack {
                    Label("Zuletzt gegessen am", systemImage: "calendar.badge.clock")
                    Spacer()
                    Text(dish.lastEaten.formatted())
                }
                .accessibilityElement(children: .combine)
            }
        }
        .navigationTitle("Gericht")
        .toolbar {
            ToolbarItem(placement: .principal) {
                Button("Gegessen") {
                    dish.lastEaten = Date()
                }
            }
            ToolbarItem(placement: .primaryAction) {
                Button("Bearbeiten") {
                    isPresentingEditView = true
                    editingDish = dish
                }
            }
        }
        .sheet(isPresented: $isPresentingEditView) {
            NavigationStack {
                DetailEditView(dish: $editingDish)
                    .navigationTitle("Gericht")
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Abbrechen") {
                                isPresentingEditView = false
                            }
                        }
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Fertig") {
                                isPresentingEditView = false
                                dish = editingDish
                            }
                        }
                    }
            }
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            DetailView(dish: .constant(Dish.sampleData[0]))
        }
    }
}
