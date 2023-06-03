//
//  ContentView.swift
//  dishes reminder
//
//  Created by Paul on 28.05.23.
//

import SwiftUI
import UniformTypeIdentifiers

struct ContentView: View {
    @Binding var dishes: [Dish]
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.isSearching) private var isSearching: Bool
    @State private var isPresentingNewDishView = false
    let loadAction: () -> Void
    let saveAction: () -> Void
    
    @State private var searchText: String = ""
    @State private var showListEmptyAlert = false
    @State private var showListImportPicker = false
    @State private var selectedListURL: URL?
    
    // Dictionary to store indexes; this is for lookup speed improvements if dishes array gets larger
    //@State private var dishIndices: [UUID: Int] = [:]
    
    var filteredDishes: [Dish] {
        if searchText.isEmpty {
            return dishes
        } else {
            return dishes.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        NavigationStack {
            List {
                // lookup performance improvement by indices array as DetailView needs binding
                ForEach(dishes.sorted(by: { $0.lastEaten < $1.lastEaten })) { dish in
                    NavigationLink(destination: DetailView(dish: getBinding(for: dish))) {
                        CardView(dish: dish)
                    }
                    .listRowBackground(Color.brown)
                }
                .onDelete(perform: delete)
            }
            .navigationTitle("Gerichte")
            .searchable(text: $searchText) {
                if filteredDishes.isEmpty {
                    Text("Kein Ergenis gefunden")
                } else {
                    ForEach(filteredDishes, id: \.name) { suggestion in
                        NavigationLink(destination: DetailView(dish: getBinding(for: suggestion))) {
                            Text(suggestion.name)
                        }
                    }
                }
            }
            .toolbar {
                Button(action: {
                    // import dishes store
                    showListImportPicker = true
                }) {
                    Image(systemName: "square.and.arrow.down")
                }
                Button(action: {
                    // export dishes store
                    do {
                        try DishesStore.shareFile()
                    } catch {
                        showListEmptyAlert = true
                        return;
                    }
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
                .accessibilityLabel("Export")
                Button(action: {
                    isPresentingNewDishView = true
                }) {
                    Image(systemName: "plus")
                }
                .accessibilityLabel("Gericht hinzufuegen")
            }
        }
        .sheet(isPresented: $isPresentingNewDishView) {
            AddDishSheet(dishes: $dishes, isPresentingNewDishView: $isPresentingNewDishView)
        }
        .onChange(of: scenePhase) { phase in
            if phase == .inactive { saveAction() }
        }
        .alert("Deine Liste ist leer", isPresented: $showListEmptyAlert) {}
        .fileImporter(
            isPresented: $showListImportPicker,
            allowedContentTypes: [.item],
            onCompletion: { result in
            if case .success(let url) = result {
                _ = DishesStore.importList(fromUrl: url)
                loadAction()
            }
        })
        /*for indices perf improvement
         
        .onAppear {
            populateDishIndexes()
        }*/
        // also dishIndexes[dish.id] = dishes.count - 1 after new dish has been added
    }
    
    /*for indices perf improvement
     
    func populateDishIndexes() {
        for (index, dish) in dishes.enumerated() {
            dishIndexes[dish.id] = index
        }
    }*/
    
    // O(n) time complexity - can be improved by the indices option above
    func getBinding(for dish: Dish) -> Binding<Dish> {
        guard let index = dishes.firstIndex(where: { $0.id == dish.id }) else {
            fatalError("Dish not found in storage!")
        }
        
        return Binding<Dish>(
            get: { dishes[index] },
            set: { dishes[index] = $0 }
        )
    }
    
    func delete(at offsets: IndexSet) {
        /*for indices perf improvement
         
        let indicesToRemove = Array(offsets)
        let sortedIndicesToRemove = indicesToRemove.sorted(by: >) // Sort in descending order

        for index in sortedIndicesToRemove {
            let dish = dishes[index]
            dishIndexes[dish.id] = nil // Remove index from the dictionary
        }*/
        
        dishes.remove(atOffsets: offsets)
    }
}



struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(dishes: .constant(Dish.sampleData), loadAction: {}, saveAction: {})
    }
}
