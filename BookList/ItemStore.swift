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
    
}

extension ItemStore {
    
    private func processItemsRequest(data: Data?, error: Error?) -> ItemsResult {
        guard let jsonData = data else {
            return .Faliure(error!)
        }
        
        return EbayAPI.itemsFromJSONData(data: jsonData,
                                         inContext: coreDataStack.mainQueueContext)
    }
    
    func fetchItems(completionHandler: @escaping (ItemsResult) -> (Void)) {
        let task = session.dataTask(with: EbayAPI.ebayURL) {
            (data, response, error) in
            var result = self.processItemsRequest(data: data, error: error)
            
            if case let .Success(items) = result {
                
                let pqc = self.coreDataStack.privateQueueContext
                
                pqc.performAndWait {
                    try! pqc.obtainPermanentIDs(for: items)
                }
                
                do {
                    try self.coreDataStack.saveChanges()
                    
                    let mainQueueItems = try self.fetchMainQueueItems()
                    result = ItemsResult.Success(mainQueueItems)
                    
                } catch {
                    result = ItemsResult.Faliure(error)
                }
                
            }
            
            
            completionHandler(result)
        }
        
        task.resume()
        
    }
    
}

extension ItemStore {
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
