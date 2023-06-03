//
//  CardView.swift
//  DishesReminder
//
//  Created by Paul on 28.05.23.
//

import SwiftUI

struct CardView: View {
    let dish: Dish
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(dish.name)
                .font(.headline)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            HStack {
                // alternative: dish.created.formatted(date: .abbreviated, time: .omitted)
                Label("\(formatDate(dish.created))", systemImage: "calendar.badge.plus")
                    .accessibilityLabel("Erstellt am \(formatDate(dish.created))")
                Spacer()
                Label("\(formatDate(dish.lastEaten))", systemImage: "calendar.badge.clock")
                    .accessibilityLabel("Zuletzt gegessen am \(formatDate(dish.created))")
                    .labelStyle(.trailingIcon)
            }
            .font(.caption)
        }
        .padding()
        .foregroundColor(Color.white)
    }
    
    private func formatDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
}

struct CardView_Previews: PreviewProvider {
    static var dish = Dish.sampleData[0]
    static var previews: some View {
        CardView(dish: dish)
            .background(Color.brown)
            .previewLayout(.fixed(width: 400, height: 60))
    }
}
