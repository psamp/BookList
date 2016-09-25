//
//  ItemCell.swift
//  BookList
//
//  Created by Princess Sampson on 9/25/16.
//  Copyright © 2016 Princess Sampson. All rights reserved.
//

import UIKit

class ItemCell: UITableViewCell {
    
    @IBOutlet var photo: UIImageView!
    @IBOutlet var photoLoadingIndicator: UIActivityIndicatorView!
    @IBOutlet var title: UILabel!
    @IBOutlet var author: UILabel!
    
    func hideAuthorLabel() {
        author.isHidden = true
    }
    
}
