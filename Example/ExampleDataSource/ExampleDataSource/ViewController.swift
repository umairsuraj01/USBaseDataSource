//
//  ViewController.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import UIKit
import USDataSource

class ViewController: UIViewController {
    private var dataSource: USArrayDataSource!
//
//    init() {
//        super.init(style: .grouped)
//        title = NSLocalizedString("USDataSources", comment: nil)
//
//        dataSource = USArrayDataSource(items: [
//            USDataSourcesExample.Table.rawValue,
//            USDataSourcesExample.SectionedTable.rawValue,
//            USDataSourcesExample.CollectionView.rawValue,
//            USDataSourcesExample.ExpandingTable.rawValue
//        ])
//
//        dataSource.cellConfigureBlock = { cell, exampleType, tableView, indexPath in
//            var title: String?
//
//            if let exampleType = exampleType as? Int, let example = USDataSourcesExample(rawValue: exampleType) {
//                switch example {
//                case .Table:
//                    title = NSLocalizedString("Table View", comment: nil)
//                case .CollectionView:
//                    title = NSLocalizedString("Collection View", comment: nil)
//                case .SectionedTable:
//                    title = NSLocalizedString("Sectioned Table", comment: nil)
//                case .ExpandingTable:
//                    title = NSLocalizedString("Expanding Table", comment: nil)
//                }
//            }
//
//            cell.textLabel?.text = title
//            cell.accessoryType = .disclosureIndicator
//        }
//
//        dataSource.tableActionBlock = { action, tableView, indexPath in
//            return false
//        }
//    }
//
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        dataSource.tableView = tableView
//    }
//
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        var viewController: UIViewController?
//        if let exampleType = dataSource.item(atIndexPath: indexPath) as? Int,
//           let example = USDataSourcesExample(rawValue: exampleType) {
//            switch example {
//            case .Table:
//                viewController = USTableViewController()
//            case .CollectionView:
//                viewController = USCollectionViewController()
//            case .SectionedTable:
//                viewController = USSectionedViewController()
//            case .ExpandingTable:
//                viewController = USExpandingViewController()
//            }
//        }
//
//        if let viewController = viewController {
//            navigationController?.pushViewController(viewController, animated: true)
//        }
//    }
}

//enum USDataSource: UInt {
//    case Table
//    case SectionedTable
//    case CollectionView
//    case ExpandingTable
//}


