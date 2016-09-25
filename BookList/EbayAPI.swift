//
//  EbayAPI.swift
//  BookList
//
//  Created by Princess Sampson on 9/25/16.
//  Copyright © 2016 Princess Sampson. All rights reserved.
//

import Foundation

enum EbayError: Error {
    case InvalidJSONData
}

enum ItemsResult {
    case Success([Item])
    case Faliure(EbayError)
}

class EbayAPI {
    
    fileprivate let ebayURL = NSURL(string: "https://de-coding-test.s3.amazonaws.com/books.json")
    
}
