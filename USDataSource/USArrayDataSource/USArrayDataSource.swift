//
//  USArrayDataSource.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import UIKit

private var USArrayKeyPathDataSourceContext = "USArrayKeyPathDataSourceContext"

class USArrayDataSource: USBaseDataSource {
    private weak var target: AnyObject?
    private var keyPath: String
    
    private lazy var items: [Any]? = {
        return target?.value(forKeyPath: keyPath) as? [Any]
    }()
    
    init(items: [Any]?) {
        self.target = nil
        self.keyPath = ""
        super.init()
        updateItems(items)
    }
    
    init(target: AnyObject, keyPath: String) {
        self.target = target
        self.keyPath = keyPath
        super.init()
        registerKVO()
    }
    
    deinit {
        unregisterKVO()
    }
    
    override func numberOfSections() -> Int {
        return 1
    }
    
    override func numberOfItems(inSection section: Int) -> Int {
        return numberOfItems()
    }
    
    override func numberOfItems() -> Int {
        if let currentFilter = currentFilter {
            return currentFilter.numberOfItems()
        } else {
            return items?.count ?? 0
        }
    }
    
    override func item(at indexPath: IndexPath) -> Any? {
        if let currentFilter = currentFilter {
            return currentFilter.item(at: indexPath)
        } else if let item = items?[indexPath.row] {
            return item
        }
        return nil
    }
    
    func clearItems() {
        items?.removeAll()
        emptyView = emptyView // hackish, force empty view state recalculation
    }
    
    func removeAllItems() {
        clearItems()
    }
    
    func updateItems(_ newItems: [Any]?) {
        unregisterKVO()
        items = newItems
        reloadData()
        registerKVO()
    }
    
    func allItems() -> [Any]? {
        return items
    }
    
    func appendItem(_ item: Any) {
        appendItems([item])
    }
    
    func appendItems(_ newItems: [Any]?) {
        guard let newItems = newItems, !newItems.isEmpty else {
            return
        }
        
        let startIndex = numberOfItems()
        
        items?.append(contentsOf: newItems)
        
        let indexPaths = indexPathsArray(withRange: NSRange(location: startIndex, length: newItems.count))
        insertCells(at: indexPaths)
    }
    
    func insertItem(_ item: Any, at index: Int) {
        insertItems([item], atIndexes: IndexSet(integer: index))
    }
    
    func insertItems(_ newItems: [Any], atIndexes indexes: IndexSet) {
        guard !newItems.isEmpty, newItems.count == indexes.count else {
            return
        }
        
        items?.insert(contentsOf: newItems, at: indexes.first!)
        
        let indexPaths = indexPathsArray(withIndexes: indexes)
        insertCells(at: indexPaths)
    }
    
    func replaceItem(at index: Int, with item: Any) {
        replaceItems(atIndexes: IndexSet(integer: index), withItemsFromArray: [item])
    }
    
    func replaceItems(in range: NSRange, withItemsFromArray otherArray: [Any]?) {
        let indexes = IndexSet(integersIn: range.location..<range.location + range.length)
        replaceItems(atIndexes: indexes, withItemsFromArray: otherArray)
    }
    
    func replaceItems(atIndexes indexes: IndexSet, withItemsFromArray array: [Any]?) {
        guard let array = array else {
            return
        }
        
        let sortedIndexes = Array(indexes).sorted() // Sort the indexes in ascending order
        
        // Replace the items one by one
        for (index, newItem) in array.enumerated() {
            let currentIndex = sortedIndexes[index]
            items?.remove(at: currentIndex)
            items?.insert(newItem, at: currentIndex)
        }
        
        let indexPaths = indexPathsArray(withIndexes: indexes)
        reloadCells(at: indexPaths)
    }

    
    // MARK: - Moving Items
    
    func moveItem(at index1: UInt, to index2: UInt) {
        let sourceIndexPath = IndexPath(row: Int(index1), section: 0)
        let destinationIndexPath = IndexPath(row: Int(index2), section: 0)
        
        guard let item = item(at: sourceIndexPath) else {
            return
        }
        
        items?.remove(at: sourceIndexPath.row)
        items?.insert(item, at: destinationIndexPath.row)
        
        moveCell(at: sourceIndexPath, to: destinationIndexPath)
    }
    
    // MARK: - Removing Items
    
    func removeItems(in range: NSRange) {
        let indexes = IndexSet(integersIn: range.location..<(range.location + range.length))
        removeItems(at: indexes)
    }
    
    func removeItem(at index: Int) {
        removeItems(at: IndexSet(integer: index))
    }
    
    func removeItems(at indexes: IndexSet) {
        let sortedIndexes = Array(indexes).sorted(by: >) // Sort the indexes in descending order
        
        for index in sortedIndexes {
            items?.remove(at: index)
        }
        
        let indexPaths = indexPathsArray(withIndexes: indexes)
        deleteCells(at: indexPaths)
    }

    
    func removeItems(_ itemsToRemove: [Any]) {
        guard let itemsToRemove = itemsToRemove as? [AnyHashable] else {
            return
        }
        
        items?.removeAll { item in
            itemsToRemove.contains(where: { $0 == item as? AnyHashable })
        }
        
        let indexPaths = items?.enumerated()
            .filter { _, item in
                itemsToRemove.contains(where: { $0 == item as? AnyHashable })
            }
            .map { IndexPath(row: $0.offset, section: 0) }
        
        if let indexPaths = indexPaths {
            deleteCells(at: indexPaths)
        }
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let item = item(at: sourceIndexPath) else {
            return
        }
        
        items?.remove(at: sourceIndexPath.row)
        items?.insert(item, at: destinationIndexPath.row)
        
        moveCell(at: sourceIndexPath, to: destinationIndexPath)
    }
    
    // MARK: - Key-value observing
    
    func registerKVO() {
        target?.addObserver(self, forKeyPath: keyPath, options: .initial, context: &USArrayKeyPathDataSourceContext)
    }
    
    func unregisterKVO() {
        target?.removeObserver(self, forKeyPath: keyPath, context: &USArrayKeyPathDataSourceContext)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let change = change, context == &USArrayKeyPathDataSourceContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == self.keyPath {
            if let changeKind = change[.kindKey] as? NSKeyValueChange, let indexes = change[.indexesKey] as? IndexSet {
                let indexPaths = indexPathsArray(withIndexes: indexes)
                
                switch changeKind {
                case .insertion:
                    insertCells(at: indexPaths)
                case .removal:
                    deleteCells(at: indexPaths)
                case .replacement:
                    reloadCells(at: indexPaths)
                default:
                    break
                }
            }
        }
    }
    
    // Helper method to convert IndexSet to an array of IndexPaths
    private func indexPathsArray(withIndexes indexes: IndexSet) -> [IndexPath] {
        return indexes.map { IndexPath(row: $0, section: 0) }
    }
    
    // Helper method to generate an array of sequential IndexPaths within a range
    private func indexPathsArray(withRange range: NSRange) -> [IndexPath] {
        return (range.location..<range.location + range.length).map { IndexPath(row: $0, section: 0) }
    }
}
