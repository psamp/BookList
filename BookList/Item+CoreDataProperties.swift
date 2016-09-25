//
//  Item+CoreDataProperties.swift
//  BookList
//
//  Created by Princess Sampson on 9/24/16.
//  Copyright © 2016 Princess Sampson. All rights reserved.
//

import Foundation
import CoreData

extension Item {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Item> {
        return NSFetchRequest<Item>(entityName: "Item");
    }

    @NSManaged public var title: String?
    @NSManaged public var author: String?
    @NSManaged public var photo: Photo?

}
