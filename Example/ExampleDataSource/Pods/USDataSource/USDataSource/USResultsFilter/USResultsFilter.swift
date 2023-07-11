//
//  USResultsFilter.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import Foundation
import UIKit

class USResultsFilter: NSObject, USDataSourceItemAccess {
    var filterPredicate: NSPredicate?
    var sections: NSMutableArray = []
    
    override init() {
        super.init()
        sections = []
    }
    
    static func filter(with predicate: NSPredicate) -> USResultsFilter? {
        let filter = USResultsFilter()
        filter.filterPredicate = predicate
        return filter
    }
    
    class func filter(with filterBlock: ((Any) -> Bool)?) -> USResultsFilter? {
        guard let filterBlock = filterBlock else {
            return nil
        }
        
        return self.filter(with: NSPredicate { object, _ in
            return filterBlock(object as Any)
        })
    }
    
    // MARK: - Item access
    
    func item(at indexPath: IndexPath) -> Any? {
        guard indexPath.section < sections.count else {
            return nil
        }
        let section = sections[indexPath.section]
        
        guard let items = section as? [Any], indexPath.row < items.count else {
            return nil
        }
        return items[indexPath.row]
    }
    
//    func indexPath(for item: Any) -> IndexPath? {
//        var indexPath: IndexPath?
//        enumerateItems { (ip, anItem, stop) in
//            if (item as AnyObject).isEqual(anItem) {
//                indexPath = ip
//            }
//        }
//        return indexPath
//    }
    
//    func enumerateItems(with itemBlock: USDataSourceEnumerator?) {
//        if itemBlock == nil {
//            return
//        }
//        var stop = false
//        for i in 0..<numberOfSections() {
//            for j in 0..<numberOfItems(inSection: i) {
//                guard let items = sections[i] as? [Any] else {
//                    continue
//                }
//                let item = items[j]
//                let indexPath = IndexPath(row: j, section: i)
//                itemBlock!(indexPath, item, &stop)
//                if stop {
//                    return
//                }
//            }
//        }
//    }
    
    func indexPath(for item: Any) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            guard let items = section as? [Any] else {
                continue
            }

            if let rowIndex = items.firstIndex(where: { ($0 as AnyObject).isEqual(item) }) {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
    }

    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        guard section < sections.count, let items = sections[section] as? [Any] else {
            return 0
        }
        return items.count
    }
    
//    func numberOfItems() -> Int {
//        var count = 0
//
//        for i in 0..<numberOfSections() {
//            count += numberOfItems(inSection: i)
//        }
//
//        return count
//    }
    
    func numberOfItems() -> Int {
        return sections.reduce(0) { (result, section) in
            if let items = section as? [Any] {
                return result + items.count
            }
            return result
        }
    }
}

