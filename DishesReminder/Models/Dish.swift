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
    var ingredients: [String] = []
    var created: Date
    var lastEaten: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case ingredients
        case created = "date_created"
        case lastEaten = "date_last_eaten"
    }
    
    init(id: UUID = UUID(), name: String, ingridients: [String], created: Date, lastEaten: Date) {
        self.id = id
        self.name = name
        self.ingredients = ingridients
        self.created = created
        self.lastEaten = lastEaten
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        created = try container.decode(Date.self, forKey: .created)
        lastEaten = try container.decode(Date.self, forKey: .lastEaten)
        
        ingredients = try container.decodeIfPresent([String].self, forKey: .ingredients) ?? []
    }
}

extension Dish {
    static var emptyDish: Dish {
        Dish(name: "", ingridients: [], created: Date(), lastEaten: Date())
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
            
            let dish = Dish(name: "Dish \(i + 1)", ingridients: ["Ingr 1", "Ingr 2"], created: createdDate, lastEaten: lastEatenDate)
            dishes.append(dish)
        }
        
        return dishes
    }()
}
