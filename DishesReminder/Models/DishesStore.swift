//
//  DishesStore.swift
//  dishes reminder
//
//  Created by Paul on 28.05.23.
//

import Foundation
import SwiftUI
import UniformTypeIdentifiers

@MainActor
class DishesStore: ObservableObject {
    static let dataTypes: [UTType] = {
        if let dataType = UTType(filenameExtension: "data", conformingTo: .item) {
            return [dataType]
        } else {
            return []
        }
    }()
    
    @Published
    public var dishes: [Dish] = []
    
    private static func fileURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("dishes.data")
    }
    
    func load() async throws {
        let task = Task<[Dish], Error> {
            let fileURL = try Self.fileURL()
            
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            
            let loadedDishes = try JSONDecoder().decode([Dish].self, from: data)
            
            return loadedDishes
        }
        
        let dishes = try await task.value
        self.dishes = dishes
    }
    
    func save(dishes: [Dish]) async throws {
        let task = Task {
            let data = try JSONEncoder().encode(dishes)
            let outfile = try Self.fileURL()
            try data.write(to: outfile)
            
            // Set UTType for the saved file - does not work
            //try FileManager.default.setAttributes([FileAttributeKey.type: UTType.utf8PlainText], ofItemAtPath: outfile.path)
        }
        _ = try await task.value
    }
    
    private static func fileExists(atURL url: URL) -> Bool {
        return FileManager.default.fileExists(atPath: url.path)
    }
    
    static func shareFile() throws {
        let fileURL = try Self.fileURL()
        
        if !fileExists(atURL: fileURL) {
            throw CustomError.fileNotFound
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let rootViewController = windowScene.windows.first?.rootViewController else {
            return;
        }
        
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        
        rootViewController.present(activityViewController, animated: true, completion: nil)
    }
    
    static func importList(fromUrl url: URL) -> Bool {
        let fileManager = FileManager.default

        do {
            let destUrl = try Self.fileURL()
            // Remove existing file if it exists
            try fileManager.removeItem(at: destUrl)
            // copy imported file
            try fileManager.copyItem(at: url, to: destUrl)
            // File copied successfully
        } catch {
            print("Error copying file: \(error)")
            return false
        }
        
        return true
    }
}
