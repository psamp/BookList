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

enum ItemError: Error {
    case ItemCreationFaliure
}

class ItemStore {
    
    let coreDataStack = CoreDataStack(modelName: "Item")
    
    let imageStore = ImageStore()
    
    let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
}

extension ItemStore {
    
    private func processItemsRequest(data: Data?, error: Error?) -> ItemsResult {
        
        guard let jsonData = data else {
            return .Failure(error!)
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
                    result = .Success(mainQueueItems)
                    
                } catch {
                    result = .Failure(error)
                }
                
            }
            
            completionHandler(result)
        }
        
        task.resume()
        
    }
    
}

extension ItemStore {
    
    private func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        
        guard let imageData = data, let image = UIImage(data: imageData) else {
            return data == nil ? .Failure(error!) : .Failure(ItemError.ItemCreationFaliure)
        }
        return .Success(image)
    }
    
    func fetchImageForItem(_ item: Item, completionHandler: @escaping (ImageResult) -> Void) {
        
        let imageKey = item.imageKey
        
        if let image = imageStore.imageForKey(imageKey!) {
            completionHandler(.Success(image))
            return
        }
        
        if let itemImageURL = item.imageURL {
            
            let imageURL = self.convertURLToHTTPS(itemImageURL)
            
            let task = session.dataTask(with: imageURL) { (data, response, error) in
                let result = self.processImageRequest(data: data, error: error)
                
                if case let .Success(image) = result {
                    item.image = image
                    self.imageStore.setImage(image, forKey: item.imageKey!)
                }
                
                completionHandler(result)
            }
            
            task.resume()
        }
    }
    
    private func convertURLToHTTPS(_ url: URL) -> URL {
        
        var components = URLComponents(string: url.absoluteString)
        components?.scheme = "https"
        
        let secureURL = components?.url
        
        return secureURL!
        
    }
}

extension ItemStore {
    func fetchMainQueueItems(predicate: NSPredicate? = nil,
                             sortDescriptors: [NSSortDescriptor]? = nil) throws -> [Item] {
        
        var mainQueueItems: [Item]?
        
        let request: NSFetchRequest<Item> = NSFetchRequest<Item>()
        request.entity = Item.entity()
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
