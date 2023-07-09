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
    
    private static func importedFileURL() -> URL? {
        return FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dev.paulober.dishes-reminder.transfer")?.appendingPathComponent("imported.dishes.data")
    }
    
    func load() async throws {
        let task = Task<[Dish], Error> {
            let fileURL = try Self.fileURL()
            
            // check if shared file has been imported by extension
            if let importedFileURL = Self.importedFileURL() {
                
                if FileManager.default.fileExists(atPath: importedFileURL.path(percentEncoded: false)) {
                    do {
                        // Check if the file exists at the destination path
                        if FileManager.default.fileExists(atPath: fileURL.path) {
                            // Remove the existing file
                            try FileManager.default.removeItem(at: fileURL)
                        }
                        
                        try FileManager.default.copyItem(at: importedFileURL, to: fileURL)
                        try FileManager.default.removeItem(at: importedFileURL)
                    } catch {
                        print("Unable to copy imported file into integrated container: \(error.localizedDescription)")
                    }
                }
            }
            
            // if file does not exist init with empty dishes array
            if !FileManager.default.fileExists(atPath: fileURL.path(percentEncoded: false)) {
                FileManager.default.createFile(atPath: fileURL.path(percentEncoded: false), contents: "[]".data(using: .utf8))
            }
            
            // load dishes from file
            guard let data = try? Data(contentsOf: fileURL) else {
                return []
            }
            print(String(data: data, encoding: .utf8) ?? "")
            // decode dishes
            let loadedDishes: [Dish] = try JSONDecoder().decode([Dish].self, from: data)
            
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
