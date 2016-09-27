//
//  ItemStore.swift
//  BookList
//
//  Created by Princess Sampson on 9/26/16.
//  Copyright © 2016 Princess Sampson. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum ImageResult: Error {
    case Success(UIImage)
    case Faliure(Error)
}

enum ItemError: Error {
    case ItemCreationFaliure
}

class ItemStore {
    let coreDataStack = CoreDataStack(modelName: Item.entity().name!)
    
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
    func processItemsRequest(data: Data?, error: Error?) {
        
    }
    
    func fetchMainQueueItems(predicate: NSPredicate? = nil,
                             sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Item] {
        var mainQueueItems: [Item]?
        
        let request: NSFetchRequest<Item> = NSFetchRequest<Item>()
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        
        let mainQueueContext = self.coreDataStack.mainQueueContext
        
        var fetchError: Error?
        
        mainQueueContext.performAndWait {
            do {
                
                mainQueueItems = try mainQueueContext.fetch(request)
                
            } catch {
                
                fetchError = error
            }
        }
        
        guard let items = mainQueueItems else {
            throw fetchError!
        }
        
        return items
        
    }
    
    
}
