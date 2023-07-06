//
//  USResultsFilter.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import Foundation

class USResultsFilter: NSObject, USDataSourceItemAccess {
    var filterPredicate: NSPredicate?
    var sections: [Any] = []
    
    override init() {
        super.init()
        sections = []
    }
    
    static func filter(with predicate: NSPredicate) -> USResultsFilter {
        let filter = USResultsFilter()
        filter.filterPredicate = predicate
        return filter
    }
    
//    static func filter(with block: @escaping (Any) -> Bool) -> USResultsFilter? {
//        guard let filterPredicate = NSPredicate { (object, _) in
//            return block(object)
//        } else {
//            return nil
//        }
//
//        return filter(with: filterPredicate)
//    }
    
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
    
    func indexPath(for item: Any) -> IndexPath? {
        var indexPath: IndexPath?
        
//        enumerateItems { (ip, anItem, stop) in
//            if item.isEqual(anItem) {
//                indexPath = ip
//                stop.pointee = true
//            }
//        }
        
        return indexPath
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
    
    func numberOfItems() -> Int {
        var count = 0
        
        for i in 0..<numberOfSections() {
            count += numberOfItems(inSection: i)
        }
        
        return count
    }
    
    func enumerateItems(with itemBlock: @escaping USDataSourceEnumerator) {
//        guard let itemBlock = itemBlock else {
//            return
//        }
//        
//        var stop = false
//        
//        for i in 0..<numberOfSections() {
//            for j in 0..<numberOfItems(inSection: i) {
//                guard let items = sections[i] as? [Any] else {
//                    continue
//                }
//                
//                let item = items[j]
//                let indexPath = IndexPath(row: j, section: i)
//                
//                itemBlock(indexPath, item, &stop)
//                
//                if stop {
//                    return
//                }
//            }
//        }
    }
}

