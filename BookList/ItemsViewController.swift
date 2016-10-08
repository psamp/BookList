//
//  ItemsViewController.swift
//  BookList
//
//  Created by Princess Sampson on 9/24/16.
//  Copyright © 2016 Princess Sampson. All rights reserved.
//

import UIKit

class ItemsViewController: UITableViewController {
    
    var items: [Item] = [] {
        didSet {
            
            tableView.reloadData()
        }
    }
    
    fileprivate var store = ItemStore()
    fileprivate let privateQueue = OperationQueue()
    
}

extension ItemsViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        privateQueue.addOperation {
            self.store.fetchItems {
                (itemResult) in
                
                OperationQueue.main.addOperation {
                    switch itemResult {
                    case let .Success(items):
                        self.items = items
                    case let .Failure(error):
                        print("Could not retrieve items because: \(error)")
                    }
                }
                
            }
        }
    }
}

extension ItemsViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        let item = items[indexPath.row]
        
        cell.title.text = item.title
        
        if let itemAuthor = item.author {
            cell.author.text = itemAuthor
            cell.author.isHidden = false
        } else {
            cell.author.isHidden = true
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let item = items[indexPath.row]
        let itemCell = cell as! ItemCell
        
        privateQueue.addOperation {
            EbayAPI.fetchImageForItem(item) { (result) in
                
                switch result {
                case let .Success(image):
                    item.image = image
                default:
                    break
                }
            }
        }
        
        itemCell.updateWith(photo: item.image ?? UIImage(named: "no-image-placeholder")!)
        
    }
    
}

