//
//  ViewController.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import UIKit
import USDataSource

class ViewController: UITableViewController {
    private var dataSource: USArrayDataSource! = USArrayDataSource(items: [
        USDataSourceExample.Table.rawValue,
        USDataSourceExample.SectionedTable.rawValue,
        USDataSourceExample.CollectionView.rawValue,
        USDataSourceExample.ExpandingTable.rawValue
    ])

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("USDataSources", comment: "")

        dataSource.tableView = tableView
        dataSource.cellConfigureBlock = { cell, exampleType, tableView, indexPath in
            var title: String?

            if let exampleType = exampleType as? Int, let example = USDataSourceExample(rawValue: exampleType) {
                switch example {
                case .Table:
                    title = NSLocalizedString("Table View", comment: "")
                case .CollectionView:
                    title = NSLocalizedString("Collection View", comment: "")
                case .SectionedTable:
                    title = NSLocalizedString("Sectioned Table", comment: "")
                case .ExpandingTable:
                    title = NSLocalizedString("Expanding Table", comment: "")
                }
            }

            (cell as? USBaseTableCell)?.textLabel?.text = title
            (cell as? USBaseTableCell)?.accessoryType = .disclosureIndicator
        }

        dataSource.tableActionBlock = { action, tableView, indexPath in
            return false
        }
        dataSource.reloadData()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var viewController: UIViewController?
        if let exampleType = dataSource.item(at: indexPath) as? Int,
           let example = USDataSourceExample(rawValue: exampleType) {
            switch example {
            case .Table:
                viewController = USTableViewController()
            case .CollectionView:
                viewController = USCollectionViewController()
            case .SectionedTable:
                viewController = USSectionedViewController()
            case .ExpandingTable:
                viewController = USExpandingViewController()
            }
        }

        if let viewController = viewController {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
}

enum USDataSourceExample: Int {
    case Table
    case SectionedTable
    case CollectionView
    case ExpandingTable
}
