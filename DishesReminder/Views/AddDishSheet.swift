//
//  AddDishView.swift
//  dishes reminder
//
//  Created by Paul on 28.05.23.
//

import SwiftUI
import AVFoundation

struct AddDishSheet: View {
    @State private var newDish = Dish.emptyDish
    @Binding var dishes: [Dish]
    @Binding var isPresentingNewDishView: Bool
    
    private var player: AVPlayer {
        AVPlayer.sharedDingPlayer
    }
    
    var body: some View {
        NavigationStack {
            DetailEditView(dish: $newDish)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Abbrechen") {
                            isPresentingNewDishView = false
                        }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Hinzufuegen") {
                            // add new dish
                            dishes.append(newDish)
                            isPresentingNewDishView = false
                            
                            // play ding sound
                            player.seek(to: .zero)
                            player.play()
                        }
                    }
                }
        }
    }
}

struct AddDishSheet_Previews: PreviewProvider {
    static var previews: some View {
        AddDishSheet(dishes: .constant(Dish.sampleData), isPresentingNewDishView: .constant(true))
    }
}
