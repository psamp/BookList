//
//  ImageStore.swift
//
//
//  Created by TJ Usiyan on 4/18/16.
//  Copyright © 2016 Buttons and Lights LLC. All rights reserved.
//

import UIKit

enum ImageResult {
    case Success(UIImage)
    case Failure(Error)
}

extension String {
    fileprivate var imageKey: NSString {
        return self as NSString
    }
    fileprivate var imageKeyPathComponents: NSString {
        return imageKey
    }
}

internal class ImageStore {
    typealias Key = String
    
    fileprivate let cache = NSCache<NSString, UIImage>()
    
    /// Creates full URL for image resource
    fileprivate func imageURLForKey(_ key: Key) -> URL {
        
        let documentsDirectories =
            FileManager.default.urls(for: .documentDirectory,
                                     in: .userDomainMask)
        let documentDirectory = documentsDirectories.first!
        
        return documentDirectory.appendingPathComponent(key.imageKeyPathComponents as String)
    }
    
    internal func setImage(_ image: UIImage, forKey key: Key) {
        cache.setObject(image, forKey: key.imageKey )
        
        
        let imageURL = imageURLForKey(key)
        
        if let data = UIImageJPEGRepresentation(image, 1.0) {
            try? data.write(to: imageURL, options: [.atomic])
        }
    }
    
    internal func imageForKey(_ key: Key) -> UIImage? {
        if let existingImage = cache.object(forKey: key.imageKey) {
            return existingImage
        }
        else {
            let imageURL = imageURLForKey(key)
            
            guard let imageFromDisk = UIImage(contentsOfFile: imageURL.path) else {
                return nil
            }
            
            cache.setObject(imageFromDisk, forKey: key.imageKey)
            return imageFromDisk
        }
    }
    
    internal func removeImageForKey(_ key: Key) {
        cache.removeObject(forKey: key.imageKey)
        
        let imageURL = imageURLForKey(key)
        do {
            try FileManager.default.removeItem(at: imageURL)
        }
        catch {
            print("Error removing the image from disk: \(error)")
        }
    }
}
