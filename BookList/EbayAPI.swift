//
//  EbayAPI.swift
//  BookList
//
//  Created by Princess Sampson on 9/25/16.
//  Copyright © 2016 Princess Sampson. All rights reserved.
//

import Foundation
import CoreData

enum EbayError: Error {
    case InvalidJSONData
}

enum ItemsResult {
    case Success([Item])
    case Faliure(Error)
}

struct EbayAPI {
    
    static let ebayURL = URL(string: "https://de-coding-test.s3.amazonaws.com/books.json")!
    
    static func itemsFromJSONData(data: Data,
                                  inContext context: NSManagedObjectContext) -> ItemsResult {
        
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data,
                                                            options: [])
            
            guard let jsonArray = jsonData as? [[String : AnyObject]] else {
                return .Faliure(EbayError.InvalidJSONData)
            }
            
            var items = [Item]()
            
            for dictionary in jsonArray {
                if let item = self.itemFrom(json: dictionary, context: context) {
                    items.append(item)
                }
            }
            
            if items.isEmpty && !jsonArray.isEmpty {
                return .Faliure(EbayError.InvalidJSONData)
            }
            
            return .Success(items)
        } catch {
            return .Faliure(error)
        }
        
    }
    
    private static func itemFrom(json: [String : AnyObject],
                                 context: NSManagedObjectContext) -> Item? {
        
        guard let title = json["title"] as? String else {
            return nil
        }
        
        let author = json["author"] as? String
        let imageURL = json["imageURL"] as? String
        
        var item: Item!
        
        let request = NSFetchRequest<Item>()
        request.entity = Item.entity()
        
        let escapeNonAlphanumericCharacters = title.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
        let predicate = NSPredicate(format: "title == '\(escapeNonAlphanumericCharacters)'", [])
        request.predicate = predicate
        
        var fetchedItems: [Item]!
        
        context.performAndWait {
            fetchedItems = try! context.fetch(request)
        }
        
        if !fetchedItems.isEmpty {
            item = fetchedItems.first!
        } else {
            context.performAndWait {
                
                item = NSEntityDescription.insertNewObject(forEntityName: "Item",
                                                           into: context) as! Item
                item.title = title
                
                if let authorName = author {
                    item.author = authorName
                }
                
                if let url = imageURL {
                    item.imageURL = URL(string: url)
                }
                
                item.imageKey = UUID().uuidString
            }
            
        }
        
        return item
    }
    
}
