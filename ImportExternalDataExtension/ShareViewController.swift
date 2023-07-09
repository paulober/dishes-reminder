//
//  ShareViewController.swift
//  ImportExternalDataExtension
//
//  Created by Paul on 08.07.23.
//

import UIKit
import UniformTypeIdentifiers
import MobileCoreServices


@objc(ShareExtensionViewControl)
class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let context = extensionContext else {
            return
        }
        let attachments = (context.inputItems.first as? NSExtensionItem)?.attachments ?? []
        let contentType = UTType.data.identifier
        for provider in attachments {
            if provider.hasItemConformingToTypeIdentifier(contentType) {
                provider.loadItem(forTypeIdentifier: contentType, options: nil) { [unowned self] (data, error) in
                    guard error == nil else { return }
                    
                    if let url = data as? URL {
                        // Handle URL
                        self.saveDishes(from: url)
                    } else if let notURL = data as? Data {
                        // Handle Data
                        print("Received binary Data")
                        do {
                            // Convert the binary plist data to a Foundation object
                            let plistObject = try PropertyListSerialization.propertyList(
                                from: notURL,
                                options: [],
                                format: nil
                            )
                            
                            // Convert the Foundation object to XML data
                            let xmlData = try PropertyListSerialization.data(
                                fromPropertyList: plistObject,
                                format: .xml,
                                options: 0
                            )
                            
                            // Convert the XML data to a string
                            if let xmlString = String(data: xmlData, encoding: .utf8) {
                                let pattern = "<string>([^<]+)<\\/string>"

                                do {
                                    let regex = try NSRegularExpression(pattern: pattern, options: [])
                                    let range = NSRange(xmlString.startIndex..<xmlString.endIndex, in: xmlString)
                                    
                                    regex.enumerateMatches(in: xmlString, options: [], range: range) { (match, _, _) in
                                        if let matchRange = match?.range(at: 1),
                                           let urlRange = Range(matchRange, in: xmlString) {
                                            let fileURLString = String(xmlString[urlRange])
                                            if let fileURL = URL(string: fileURLString) {
                                                print("File URL: \(fileURL)")
                                                self.saveDishes(from: fileURL)
                                                context.completeRequest(returningItems: [])
                                            }
                                        }
                                    }
                                } catch {
                                    print("Error extracting file URL: \(error)")
                                }
                            }
                        } catch {
                            print("Error converting plist: \(error)")
                        }
                    } else {
                        // Handle Unknown Type
                        print("Received Unknown Type")
                    }
                }
            }
        }
        context.completeRequest(returningItems: [])
    }
    
    private func saveDishes(from attachementURL: URL) {
        // not suitable for big files as they are loaded into apps memory on launch and you don't want app to infitly crash because out of memory ;)
        //let userDefaults = UserDefaults(suiteName: "group.dev.paulober.dishes-reminder.transfer")
        guard let destinationURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.dev.paulober.dishes-reminder.transfer")?.appendingPathComponent("imported.dishes.data") else {
            return
        }
        
        do {
            try FileManager.default.copyItem(at: attachementURL, to: destinationURL)
            print("Imported file saved to shared container: \(destinationURL)")
        } catch {
            print("Error saving file to shared container: \(error.localizedDescription)")
        }
    }
}
