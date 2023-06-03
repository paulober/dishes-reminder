//
//  Dish.swift
//  dishes reminder
//
//  Created by Paul on 28.05.23.
//

import Foundation

struct Dish: Identifiable, Codable {
    var id: UUID
    var name: String
    var created: Date
    var lastEaten: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case created = "date_created"
        case lastEaten = "date_last_eaten"
    }
    
    init(id: UUID = UUID(), name: String, created: Date, lastEaten: Date) {
        self.id = id
        self.name = name
        self.created = created
        self.lastEaten = lastEaten
    }
}

extension Dish {
    static var emptyDish: Dish {
        Dish(name: "", created: Date(), lastEaten: Date())
    }
}

extension Dish {
    static let sampleData: [Dish] = {
        var dishes: [Dish] = []
        
        let calendar = Calendar.current
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        // Set the start date as April 26, 2023
        var dateComponents = DateComponents()
        dateComponents.year = 2023
        dateComponents.month = 4
        dateComponents.day = 26
        guard let startDate = calendar.date(from: dateComponents) else {
            return dishes
        }
        
        for i in 0..<4 {
            let createdDate = calendar.date(byAdding: .day, value: i, to: startDate)!
            let lastEatenDate = calendar.date(byAdding: .day, value: i + 1, to: startDate)!
            
            let dish = Dish(name: "Dish \(i + 1)", created: createdDate, lastEaten: lastEatenDate)
            dishes.append(dish)
        }
        
        return dishes
    }()
}
