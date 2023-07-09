//
//  EditableRow.swift
//  DishesReminder
//
//  Created by Paul on 26.06.23.
//

import SwiftUI

struct EditableRow: View {
    @Binding var text: String
    
    var body: some View {
        TextField("Zutat benennen", text: $text)
    }
}

struct EditableRow_Previews: PreviewProvider {
    static var previews: some View {
        EditableRow(text: .constant("Ingr"))
    }
}
