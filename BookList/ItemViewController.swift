//
//  ItemViewController.swift
//  BookList
//
//  Created by Princess Sampson on 9/24/16.
//  Copyright © 2016 Princess Sampson. All rights reserved.
//

import UIKit

class ItemViewController: UITableViewController {
    
    var items: [Item] = []
    fileprivate var store = ItemStore()
    
}

extension ItemViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        store.fetchItems {
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
        
        tableView.reloadData()
        
    }
}

extension ItemViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ItemCell", for: indexPath) as! ItemCell
        
        let item = items[indexPath.row]
        
        cell.title.text = item.title
        
        if let itemAuthor = item.author {
            cell.author.text = itemAuthor
        } else {
            cell.author.isHidden = true
        }
        
        print("\n\n\ngiving: \(cell)")
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let item = items[indexPath.row]
        
        store.fetchImageForItem(item) { (result) in
            
            OperationQueue.main.addOperation {
                
                let itemIndex = self.items.index(of: item)
                let itemIndexPath = IndexPath(row: itemIndex!, section: 0)
                
                if let cell = self.tableView(self.tableView,
                                             cellForRowAt: itemIndexPath) as? ItemCell {
                    cell.updateWith(photo: item.image)
                }
                
                
            }
            
        }
    }
    
}

