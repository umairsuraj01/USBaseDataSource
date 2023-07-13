//
//  USTableViewController.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 11/07/2023.
//

import UIKit

class USTableViewController: UITableViewController {
    private var dataSource: USArrayDataSource!
    
    init() {
        super.init(style: .plain)
        title = "Simple Table"
        
        var items = [Any]()
        
        for _ in 0..<5 {
            items.append(arc4random_uniform(10000))
        }
        
        dataSource = USArrayDataSource(items: items)
        dataSource.rowAnimation = .right
        dataSource.tableActionBlock = { action, tableView, indexPath in
            return true
        }
        dataSource.tableDeletionBlock = { aDataSource, tableView, indexPath in
            (aDataSource as? USArrayDataSource)?.removeItem(at: indexPath.row)
        }
        dataSource.cellConfigureBlock = { cell, number, tableView, indexPath in
            (cell as? USBaseTableCell)?.textLabel?.text = (number as? NSNumber)?.stringValue
        }
        
        let noItemsLabel = UILabel()
        noItemsLabel.text = "No Items"
        noItemsLabel.font = UIFont.boldSystemFont(ofSize: 18.0)
        noItemsLabel.textAlignment = .center
        dataSource.emptyView = noItemsLabel
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateBarButtonItems()
        
        dataSource.tableView = tableView
    }
    
    @objc func addRow() {
        dataSource.appendItem(arc4random_uniform(10000))
    }
    
    @objc func toggleEditing() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        updateBarButtonItems()
    }
    
    func updateBarButtonItems() {
        let barButtonItems: [UIBarButtonItem] = [
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addRow)),
            UIBarButtonItem(barButtonSystemItem: (tableView.isEditing ? .done : .edit), target: self, action: #selector(toggleEditing))
        ]
        
        navigationItem.rightBarButtonItems = barButtonItems
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = dataSource.item(at: indexPath)
        print("selected item \(String(describing: item))")
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

