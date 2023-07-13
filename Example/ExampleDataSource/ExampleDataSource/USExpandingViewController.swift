//
//  USExpandingViewController.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 11/07/2023.
//

import UIKit

class USExpandingViewController: UITableViewController {
    private var dataSource: USExpandingDataSource!
    
    init() {
        super.init(style: .grouped)
        title = "Expanding Table"
        dataSource = USExpandingDataSource(items: nil)
        dataSource.rowAnimation = .right
        dataSource.cellConfigureBlock = { cell, item, tableView, indexPath in
            if let item = item as? String {
                (cell as? USBaseTableCell)?.textLabel?.text = item
                (cell as? USBaseTableCell)?.textLabel?.textAlignment = .center
                (cell as? USBaseTableCell)?.textLabel?.textColor = .darkGray
            } else if let item = item as? NSNumber {
                (cell as? USBaseTableCell)?.textLabel?.text = item.stringValue
                (cell as? USBaseTableCell)?.textLabel?.textAlignment = .left
                (cell as? USBaseTableCell)?.textLabel?.textColor = .red
            }
        }
        dataSource.collapsedSectionCountBlock = { section, sectionIndex in
            return 1 + sectionIndex
        }
        
        for i in 0..<3 {
            let section = USSection.sectionWithItems([
                String(format: "Tap to Toggle (%@ row%@)", NSNumber(value: 1 + i), (1 + i != 1 ? "s" : "")),
                2, 3, 4
            ])
            dataSource.appendSection(newSection: section)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dataSource.tableView = tableView
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            dataSource.toggleSection(at: indexPath.section)
        }
    }
}

