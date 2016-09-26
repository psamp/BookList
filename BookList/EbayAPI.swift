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

class EbayAPI {
    
    static let ebayURL = NSURL(string: "https://de-coding-test.s3.amazonaws.com/books.json")
    
}

extension EbayAPI {
    
    static func itemsFromJSONData(data: NSData,
                          inContext context: NSManagedObjectContext) -> ItemsResult {
        do {
        
        } catch {
        
            return .Faliure(error)
        }
    
    }
    
    private func itemFrom(json: [String: AnyObject],
                          context: NSManagedObjectContext) -> Item? {
        
        guard let title = json["title"] as? String,
            let author = json["author"] as? String,
            let imageURL = json["imageURL"] as? String else {
                return nil
        }
        
        var item: Item!
        
        let request: NSFetchRequest<Item> = NSFetchRequest()
        let predicate = NSPredicate(format: "title == \(title)")
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
                item.author = author
                item.imageURL = URL(string: imageURL)
                item.imageKey = UUID().uuidString
            }
            
        }
        
        return item
    }
    
}
