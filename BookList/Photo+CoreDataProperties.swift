//
//  Photo+CoreDataProperties.swift
//  BookList
//
//  Created by Princess Sampson on 9/24/16.
//  Copyright © 2016 Princess Sampson. All rights reserved.
//

import Foundation
import CoreData

extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo");
    }

    @NSManaged public var url: String?
    @NSManaged public var item: Item?

}
