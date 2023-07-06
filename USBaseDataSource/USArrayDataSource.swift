//
//  USArrayDataSource.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import UIKit
import CoreData

class USArrayDataSourceItemsContainer: NSObject {
    var items: [Any]
    init(items: [Any]) {
        self.items = items
        super.init()
    }
}


private var USArrayKeyPathDataSourceContext = "USArrayKeyPathDataSourceContext"

class USArrayDataSource: USBaseDataSource {
    private var target: AnyObject?
    private var keyPath: String
    private var items: NSMutableArray?
    
    init(items: [Any]?) {
        let itemsContainer = USArrayDataSourceItemsContainer(items: items ?? [])
        self.target = itemsContainer
        self.keyPath = "items"
        super.init()
        registerKVO()
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
    
    private var mutableItems: NSMutableArray {
        if items == nil {
            items = target?.mutableArrayValue(forKey: keyPath)
        }
        return items!
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
        } else if let row = items?.object(at: indexPath.row) {
            return row
        }
        return nil
    }
    
    func clearItems() {
        items?.removeAllObjects()
        emptyView = emptyView // hackish, force empty view state recalculation
    }
    
    func removeAllItems() {
        clearItems()
    }
    
    func updateItems(_ newItems: [Any]?) {
        unregisterKVO()
        items?.setArray(newItems ?? [])
        reloadData()
        registerKVO()
    }
    
    func allItems() -> [Any]? {
        return items as? [Any]
    }
    
    func appendItem(_ item: Any) {
        appendItems([item])
    }
    
    func appendItems(_ newItems: [Any]?) {
        guard let newItems = newItems, !newItems.isEmpty else {
            return
        }
        
        let indexSet = IndexSet(integersIn: numberOfItems()..<numberOfItems() + newItems.count)
        insertItems(newItems, atIndexes: indexSet)
    }
    
    func insertItem(_ item: Any, at index: Int) {
        insertItems([item], atIndexes: IndexSet(integer: index))
    }
    
    func insertItems(_ newItems: [Any], atIndexes indexes: IndexSet) {
        guard !newItems.isEmpty, newItems.count == indexes.count else {
            return
        }
        
        mutableItems.insert(newItems, at: indexes)
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
        mutableItems.replaceObjects(at: indexes, with: array)
    }

    
    // MARK: - Moving Items

    func moveItem(at index1: UInt, to index2: UInt) {
        let indexPath1 = IndexPath(row: Int(index1), section: 0)
        let indexPath2 = IndexPath(row: Int(index2), section: 0)
        
        guard let item = item(at: indexPath1) else {
            return
        }
        
        unregisterKVO()
        items?.remove(item)
        items?.insert(item, at: Int(index2))
        
        moveCell(at: indexPath1, to: indexPath2)
        registerKVO()
    }

    // MARK: - Removing Items

    func removeItems(in range: NSRange) {
        let indexes = IndexSet(integersIn: range.location..<(range.location + range.length))
        removeItems(at: indexes)
    }

    func removeItem(at index: UInt) {
        removeItems(at: IndexSet(integer: Int(index)))
    }

    func removeItems(at indexes: IndexSet) {
        items?.removeObjects(at: indexes)
    }

    func removeItems(_ itemsToRemove: [Any]) {
        items?.removeObjects(in: itemsToRemove)
    }

    // MARK: - UITableViewDataSource

    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        guard let item = item(at: sourceIndexPath) else {
            return
        }
        
        unregisterKVO()
        items?.remove(item)
        items?.insert(item, at: destinationIndexPath.row)
        registerKVO()
    }

    // MARK: - Key-value observing

    private let USArrayKeyPathDataSourceContext = UnsafeMutableRawPointer(mutating: "USArrayKeyPathDataSourceContext")

    func registerKVO() {
        target?.addObserver(self, forKeyPath: keyPath, options: .initial, context: USArrayKeyPathDataSourceContext)
    }

    func unregisterKVO() {
        target?.removeObserver(self, forKeyPath: keyPath, context: USArrayKeyPathDataSourceContext)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, let change = change, context == USArrayKeyPathDataSourceContext else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
            return
        }
        
        if keyPath == self.keyPath {
            if let changeKind = change[.kindKey] as? NSKeyValueChange, let indexes = change[.indexesKey] as? IndexSet {
                let indexPaths = Self.indexPathArray(with: indexes, inSection: 0)
                
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

    
}
