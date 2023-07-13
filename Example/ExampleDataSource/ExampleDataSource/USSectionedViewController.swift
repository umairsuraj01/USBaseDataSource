//
//  USSectionedViewController.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 11/07/2023.
//

import UIKit

let kHeaderHeight: CGFloat = 30.0
let kFooterHeight: CGFloat = 30.0

class USSectionedViewController: UITableViewController {
    private var dataSource: USSectionedDataSource!

    init() {
        super.init(style: .grouped)
        title = "Sectioned Table"
        dataSource = USSectionedDataSource(section: Self.sectionWithRandomNumber())
        dataSource.rowAnimation = .fade
        dataSource.tableActionBlock = { actionType, tableView, indexPath in
            return true
        }
        dataSource.tableDeletionBlock = { aDataSource, tableView, indexPath in
            (aDataSource as? USSectionedDataSource)?.removeItem(at: indexPath)
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
        
        tableView.register(USBaseHeaderFooterView.self, forHeaderFooterViewReuseIdentifier: USBaseHeaderFooterView.identifier())
        
        dataSource.tableView = tableView
    }
    
    private static func sectionWithRandomNumber() -> USSection {
        let section = USSection.sectionWithItems([NSNumber(value: arc4random_uniform(10000))])
        section.headerHeight = kHeaderHeight
        section.footerHeight = kFooterHeight
        section.header = "Section Header"
        section.footer = "Section Footer"

        return section
    }
    
    @objc func addRow() {
        let newItem = NSNumber(value: arc4random_uniform(10000))

        if dataSource.numberOfSections() == 0 || arc4random_uniform(2) == 0 {
            // new section
            dataSource.appendSection(newSection: Self.sectionWithRandomNumber())
        } else {
            // new row
            let section = Int(arc4random_uniform(UInt32(dataSource.numberOfSections())))
            let row = Int(arc4random_uniform(UInt32(dataSource.numberOfItems(inSection: section))))
            dataSource.insertItem(item: newItem, at: IndexPath(row: row, section: section))
        }
    }
    
    @objc func toggleEditing() {
        tableView.setEditing(!tableView.isEditing, animated: true)
        
        updateBarButtonItems()
    }
    
    private func updateBarButtonItems() {
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

