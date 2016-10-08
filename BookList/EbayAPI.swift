//
//  EbayAPI.swift
//  BookList
//
//  Created by Princess Sampson on 9/25/16.
//  Copyright © 2016 Princess Sampson. All rights reserved.
//

import Foundation
import CoreData
import UIKit

enum EbayError: Error {
    case InvalidJSONData
}

enum ItemsResult {
    case Success([Item])
    case Failure(Error)
}

struct EbayAPI {
    
    static let ebayURL = URL(string: "https://calm-mountain-87063.herokuapp.com/books.json")!
    fileprivate static let imageStore = ImageStore()
    
    fileprivate static let session: URLSession = {
        let config = URLSessionConfiguration.default
        return URLSession(configuration: config)
    }()
    
}

extension EbayAPI {
    
    static func itemsFromJSONData(data: Data,
                                  inContext context: NSManagedObjectContext) -> ItemsResult {
        
        do {
            let jsonData = try JSONSerialization.jsonObject(with: data,
                                                            options: [])
            
            guard let jsonArray = jsonData as? [[String : AnyObject]] else {
                return .Failure(EbayError.InvalidJSONData)
            }
            
            var items = [Item]()
            
            for dictionary in jsonArray {
                if let item = self.itemFrom(json: dictionary, context: context) {
                    items.append(item)
                }
            }
            
            if items.isEmpty && !jsonArray.isEmpty {
                return .Failure(EbayError.InvalidJSONData)
            }
            
            return .Success(items)
        } catch {
            return .Failure(error)
        }
        
    }
    
    private static func itemFrom(json: [String : AnyObject],
                                 context: NSManagedObjectContext) -> Item? {
        
        guard let title = json["title"] as? String else {
            return nil
        }
        
        let request = NSFetchRequest<Item>()
        request.entity = Item.entity()
        
        let escapeNonAlphanumericCharacters = title.addingPercentEncoding(withAllowedCharacters: CharacterSet.alphanumerics)
        let predicate = NSPredicate(format: "title == '\(escapeNonAlphanumericCharacters)'", [])
        request.predicate = predicate
        
        var item: Item!
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
                
                if let authorName = json["author"] as? String  {
                    item.author = authorName
                }
                
                if let url = json["image_url"] as? String {
                    item.imageURL = URL(string: url)
                }
            }
        }
        
        return item
    }
}

extension EbayAPI {
    
    private static func processImageRequest(data: Data?, error: Error?) -> ImageResult {
        
        guard let imageData = data, let image = UIImage(data: imageData) else {
            return data == nil ? .Failure(error!) : .Failure(ItemError.ItemCreationFaliure)
        }
        return .Success(image)
    }
    
    static func fetchImageForItem(_ item: Item, completionHandler: @escaping (ImageResult) -> Void) {
        
        if let imageKey = item.imageKey,
            let image = imageStore.imageForKey(imageKey) {
            item.image = image
            completionHandler(.Success(image))
            return
        }
        
        if let optImageURL = item.imageURL {
            
            let imageURL = EbayAPI.convertURLToHTTPS(optImageURL)
            
            let task = session.dataTask(with: imageURL) { (data, response, error) in
                let result = self.processImageRequest(data: data, error: error)
                
                switch result {
                case let .Success(image):
                    item.imageKey = UUID().uuidString
                    imageStore.setImage(image, forKey: item.imageKey!)
                default:
                    break
                }
                
                completionHandler(result)
                return
            }
            
            task.resume()
        }
        
        completionHandler(.NoImage)
    }
    
    private static func convertURLToHTTPS(_ url: URL) -> URL {
        
        var components = URLComponents(string: url.absoluteString)
        components?.scheme = "https"
        
        let secureURL = components?.url
        
        return secureURL!
        
    }
}
