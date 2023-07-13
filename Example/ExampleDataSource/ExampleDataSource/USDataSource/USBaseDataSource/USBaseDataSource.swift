//
//  USBaseDataSource.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import UIKit

enum USCellActionType: UInt {
    case edit
    case move
}

class USBaseDataSource: NSObject, UITableViewDataSource, UICollectionViewDataSource, USDataSourceItemAccess {
    var cellClass: AnyClass = USBaseTableCell.self
    var collectionViewSupplementaryElementClass: USBaseCollectionReusableView.Type = USBaseCollectionReusableView.self
    var rowAnimation: UITableView.RowAnimation = .automatic
    var cachedSeparatorStyle: UITableViewCell.SeparatorStyle = .none
    var currentFilter: USDataSourceItemAccess?
    var cellConfigureBlock: ((Any, Any, Any, IndexPath) -> Void)?
    var cellCreationBlock: ((Any, Any, IndexPath) -> Any)?
    var collectionSupplementaryConfigureBlock: ((Any, String, Any, IndexPath) -> Void)?
    var collectionSupplementaryCreationBlock: ((String, Any, IndexPath) -> Any)?
    var tableActionBlock: ((USCellActionType, UITableView, IndexPath) -> Bool)?
    var tableDeletionBlock: ((USBaseDataSource, UITableView, IndexPath) -> Void)?
    var tableView: UITableView? {
        didSet {
            if let tableView = tableView {
                tableView.dataSource = self
            }
            updateEmptyView()
        }
    }
    var collectionView: UICollectionView? {
        didSet {
            if let collectionView = collectionView {
                collectionView.dataSource = self
            }
            updateEmptyView()
        }
    }
    var emptyView: UIView? {
        didSet {
            if let emptyView = emptyView {
                emptyView.isHidden = true
                updateEmptyView()
            }
        }
    }
    
    // MARK: - init
    
    override init() {
        super.init()
        self.cellClass = USBaseTableCell.self
        self.collectionViewSupplementaryElementClass = USBaseCollectionReusableView.self
        self.rowAnimation = .automatic
        self.cachedSeparatorStyle = .none
    }
    
    deinit {
        if let emptyView = emptyView {
            emptyView.removeFromSuperview()
        }
        currentFilter = nil
        cellConfigureBlock = nil
        cellCreationBlock = nil
        collectionSupplementaryConfigureBlock = nil
        collectionSupplementaryCreationBlock = nil
        tableActionBlock = nil
        tableDeletionBlock = nil
        tableView?.dataSource = nil
        collectionView?.dataSource = nil
    }
    
    // MARK: - USBaseDataSource
    
    func item(at indexPath: IndexPath) -> Any? {
        fatalError("Subclass must override this method")
    }
    
    func numberOfSections() -> Int {
        fatalError("Subclass must override this method")
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        fatalError("Subclass must override this method")
    }
    
    func numberOfItems() -> Int {
        var count = 0
        
        for i in 0..<numberOfSections() {
            count += numberOfItems(inSection: i)
        }
        
        return count
    }
    
    func indexPath(for item: Any) -> IndexPath? {
        for section in 0..<numberOfSections() {
            for row in 0..<numberOfItems(inSection: section) {
                let indexPath = IndexPath(row: row, section: section)
                if self.item(at: indexPath) as AnyObject === item as AnyObject {
                    return indexPath
                }
            }
        }
        
        return nil
    }
    
    func enumerateItems(with itemBlock: USDataSourceEnumerator?) {
        if itemBlock == nil {
            return
        }
        
        var stop = false
        let dataSource = currentFilter
        
        for i in 0..<numberOfSections() {
            for j in 0..<numberOfItems(inSection: i) {
                let indexPath = IndexPath(row: j, section: i)
                let item = dataSource?.item(at: indexPath)
                
                if let unwrappedItem = item {
                    itemBlock!(indexPath, unwrappedItem, &stop)
                }
                
                if stop {
                    break
                }
            }
            
            if stop {
                break
            }
        }
    }
    
    
    
    func reloadData() {
        currentFilter = nil
        tableView?.reloadData()
        collectionView?.reloadData()
    }
    
    // MARK: - Cell Configuration
    
    func configureCell(_ cell: Any, for item: Any, parentView: Any, indexPath: IndexPath) {
        cellConfigureBlock?(cell, item, parentView, indexPath)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems(inSection: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: USBaseTableCell
        if let cellCreationBlock = self.cellCreationBlock {
            cell = cellCreationBlock(item as Any, tableView, indexPath) as! USBaseTableCell
        } else if let cellClass = self.cellClass as? USBaseTableCell.Type {
            cell = cellClass.cellForTableView(tableView)
        } else {
            // Handle the case when cellClass is not a subclass of USBaseTableCell
            // You can either return a default cell or throw an error
            // For example:
            fatalError("cellClass should be a subclass of USBaseTableCell")
        }
        let item = self.item(at: indexPath)
        configureCell(cell, for: item as Any, parentView: tableView, indexPath: indexPath)
        
        return cell
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if let tableActionBlock = self.tableActionBlock {
            return tableActionBlock(.move, tableView, indexPath)
        }
        return false
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if let tableActionBlock = self.tableActionBlock {
            return tableActionBlock(.edit, tableView, indexPath)
        }
        return true
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if let tableDeletionBlock = self.tableDeletionBlock {
            tableDeletionBlock(self, tableView, indexPath)
        }
    }

    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(inSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: UICollectionViewCell
        if let cellCreationBlock = self.cellCreationBlock {
            cell = cellCreationBlock(item as Any, collectionView, indexPath) as! USBaseCollectionCell
        } else if let cellClass = self.cellClass as? USBaseCollectionCell.Type {
            cell = cellClass.cellForCollectionView(collectionView, indexPath: indexPath)
        } else {
            // Handle the case when cellClass is not a subclass of USBaseCollectionCell
            // You can either return a default cell or throw an error
            // For example:
            fatalError("cellClass should be a subclass of USBaseCollectionCell")
        }
        let item = self.item(at: indexPath)
        configureCell(cell, for: item as Any, parentView: collectionView, indexPath: indexPath)
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }
    
    func collectionView(_ cv: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var supplementaryView: UICollectionReusableView?
        
        if let creationBlock = collectionSupplementaryCreationBlock {
            supplementaryView = creationBlock(kind, cv, indexPath) as? UICollectionReusableView
        } else {
            supplementaryView = collectionViewSupplementaryElementClass.supplementaryView(for: cv, kind: kind, indexPath: indexPath)
        }
        
        if supplementaryView == nil {
            supplementaryView = collectionViewSupplementaryElementClass.supplementaryView(for: cv, kind: kind, indexPath: indexPath)
        }
        
        if let configureBlock = collectionSupplementaryConfigureBlock {
            configureBlock(supplementaryView as Any, kind, cv, indexPath)
        }
        
        return supplementaryView!
    }
    
    func setEmptyView(_ emptyView: UIView) {
        if let currentEmptyView = self.emptyView {
            currentEmptyView.removeFromSuperview()
        }
        
        self.emptyView = emptyView
        emptyView.isHidden = true
        
        updateEmptyView()
    }
    
    func updateEmptyView() {
        guard let emptyView = self.emptyView else {
            return
        }
        
        let tableView = self.tableView
        let collectionView = self.collectionView
        let targetView = tableView ?? collectionView
        
        guard let targetView = targetView else {
            return
        }
        
        if emptyView.superview != targetView {
            targetView.addSubview(emptyView)
        }
        
        let shouldShowEmptyView = numberOfItems() == 0
        let isShowingEmptyView = !emptyView.isHidden
        
        if shouldShowEmptyView {
            if let separatorStyle = tableView?.separatorStyle, separatorStyle != .none {
                self.cachedSeparatorStyle = separatorStyle
                tableView?.separatorStyle = .none
            }
        } else if cachedSeparatorStyle != .none {
            tableView?.separatorStyle = cachedSeparatorStyle
        }

        if shouldShowEmptyView == isShowingEmptyView {
            return
        }
        
        if emptyView.frame == .zero {
            var frame = targetView.bounds.inset(by: targetView.contentInset)
            
            if let tableHeaderView = tableView?.tableHeaderView {
                frame.size.height -= tableHeaderView.frame.height
            }
            
            emptyView.frame = frame
            emptyView.autoresizingMask = targetView.autoresizingMask
        }
        
        emptyView.isHidden = !shouldShowEmptyView
        
        if shouldShowEmptyView {
            collectionView?.reloadData()
        }
    }
    
    class func indexPathArray(with indexSet: IndexSet, inSection section: Int) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        
        indexSet.forEach { index in
            indexPaths.append(IndexPath(row: index, section: section))
        }
        
        return indexPaths
    }

    class func indexPathArray(with range: NSRange, inSection section: Int) -> [IndexPath] {
        let indexSet = IndexSet(integersIn: range.lowerBound..<range.upperBound)
        return indexPathArray(with: indexSet, inSection: section)
    }
    
    func insertCells(at indexPaths: [IndexPath]) {
        tableView?.insertRows(at: indexPaths, with: rowAnimation)
        
        collectionView?.insertItems(at: indexPaths)
        
        updateEmptyView()
    }
    
    func deleteCells(at indexPaths: [IndexPath]) {
        tableView?.deleteRows(at: indexPaths, with: rowAnimation)
        
        collectionView?.deleteItems(at: indexPaths)
        
        updateEmptyView()
    }
    
    func reloadCells(at indexPaths: [IndexPath]) {
        tableView?.reloadRows(at: indexPaths, with: rowAnimation)
        
        collectionView?.reloadItems(at: indexPaths)
    }
    
    func moveCell(at index1: IndexPath, to index2: IndexPath) {
        tableView?.moveRow(at: index1, to: index2)
        
        collectionView?.moveItem(at: index1, to: index2)
    }
    
    func moveSection(at index1: Int, to index2: Int) {
        tableView?.moveSection(index1, toSection: index2)
        
        collectionView?.moveSection(index1, toSection: index2)
    }
    
    func insertSections(at indexes: IndexSet) {
        tableView?.insertSections(indexes, with: rowAnimation)
        
        collectionView?.insertSections(indexes)
        
        updateEmptyView()
    }
    
    func deleteSections(at indexes: IndexSet) {
        tableView?.deleteSections(indexes, with: rowAnimation)
        
        collectionView?.deleteSections(indexes)
        
        updateEmptyView()
    }
    
    func reloadSections(at indexes: IndexSet) {
        tableView?.reloadSections(indexes, with: rowAnimation)
        
        collectionView?.reloadSections(indexes)
    }
    
    func setCurrentFilter(_ newFilter: USResultsFilter?) {
        let currentFilter = self.currentFilter
        
        var inserts = [IndexPath]()
        var deletes = [IndexPath]()
        
        if newFilter == nil && currentFilter != nil {
            self.currentFilter = nil
            
            // Restore objects that did not pass the current filter.
            enumerateItems { (indexPath, item, stop) in
                if !((currentFilter as? USResultsFilter)?.filterPredicate?.evaluate(with: item) ?? false) {
                    inserts.append(indexPath)
                }
            }
            
            if inserts.count > 0 {
                insertCells(at: inserts)
            }
        } else if newFilter != nil && currentFilter == nil {
            // No current filter. Remove any object not passing the new filter.
            newFilter!.sections.removeAllObjects()
            
            for i in 0..<numberOfSections() {
                var sectionItems = [Any]()
                
                for j in 0..<numberOfItems(inSection: i) {
                    let indexPath = IndexPath(row: j, section: i)
                    let item = item(at:indexPath)
                    if !(newFilter!.filterPredicate?.evaluate(with: item) ?? false) {
                        deletes.append(indexPath)
                    } else {
                        sectionItems.append(item as Any)
                    }
                }
                
                newFilter!.sections.add(sectionItems)
            }
            
            self.currentFilter = newFilter
            
            if deletes.count > 0 {
                deleteCells(at: deletes)
            }
        } else if newFilter != nil && currentFilter != nil {
            // Changing active filter
            
            enumerateItems { (indexPath, item, stop) in
                deletes.append(indexPath)
            }
            
            newFilter!.sections.removeAllObjects()
            
            self.currentFilter = nil
            
            for i in 0..<numberOfSections() {
                var sectionItems = [Any]()
                
                for j in 0..<numberOfItems(inSection: i) {
                    let indexPath = IndexPath(row: j, section: i)
                    let item = item(at: indexPath)
                    if newFilter!.filterPredicate?.evaluate(with: item) ?? false {
                        inserts.append(IndexPath(row: sectionItems.count, section: i))
                        sectionItems.append(item as Any)
                    }
                }
                
                newFilter!.sections.add(sectionItems)
            }
            
            self.currentFilter = newFilter
            
            let processIndexUpdatesBlock = {
                if deletes.count > 0 {
                    self.deleteCells(at: deletes)
                }
                
                if inserts.count > 0 {
                    self.insertCells(at: inserts)
                }
            }
            
            if let tableView = self.tableView {
                tableView.beginUpdates()
                processIndexUpdatesBlock()
                tableView.endUpdates()
            }
            
            if let collectionView = self.collectionView {
                collectionView.performBatchUpdates({
                    processIndexUpdatesBlock()
                }, completion: nil)
            }
        }
    }
}

