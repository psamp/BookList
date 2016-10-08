//
//  Item+CoreDataProperties.swift
//  BookList
//
//  Created by Princess Sampson on 10/8/16.
//  Copyright © 2016 Princess Sampson. All rights reserved.
//

import Foundation
import CoreData
import UIKit


extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item");
    }

    @NSManaged public var author: String?
    @NSManaged public var imageKey: String?
    @NSManaged public var imageURL: URL?
    @NSManaged public var title: String?
    @NSManaged public var image: UIImage?

}
