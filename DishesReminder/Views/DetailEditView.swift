//
//  DetailEditView.swift
//  DishesReminder
//
//  Created by Paul on 28.05.23.
//

import SwiftUI

struct DetailEditView: View {
    @Binding
    var dish: Dish
    
    var body: some View {
        Form {
            Section(header: Text("Gericht Informationen")) {
                TextField("Name", text: $dish.name)
                
                Button(action: {
                    dish.ingredients.append("Zutat")
                }) {
                    Text("Weitere Zutat hinzufuegen")
                }
                
                List {
                    ForEach(dish.ingredients.indices, id: \.self) { index in
                        EditableRow(text: $dish.ingredients[index])
                    }
                    .onDelete(perform: deleteIngridient)
                }
            }
        }
    }
    
    func deleteIngridient(at offset: IndexSet) {
        dish.ingredients.remove(atOffsets: offset)
    }
}

struct DetailEditView_Previews: PreviewProvider {
    static var previews: some View {
        DetailEditView(dish: .constant(Dish.sampleData[0]))
    }
}
