//
//  USBaseDataSource.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import UIKit

import UIKit

class USBaseDataSource: NSObject, UITableViewDataSource, UICollectionViewDataSource {
    var cellClass: USBaseTableCell.Type = USBaseTableCell.self
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
    var tableView: UITableView! {
        didSet {
            if let tableView = tableView {
                tableView.dataSource = self
            }
            updateEmptyView()
        }
    }
    var collectionView: UICollectionView! {
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
        tableView.dataSource = nil
        collectionView.dataSource = nil
    }
    
    // MARK: - USBaseDataSource
    
    func item(at indexPath: IndexPath) -> Any {
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
                
                if item(at: indexPath) as AnyObject === item as AnyObject {
                    return indexPath
                }
            }
        }
        
        return nil
    }
    
    func enumerateItems(with itemBlock: ((IndexPath, Any, inout Bool) -> Void)?) {
        if itemBlock == nil {
            return
        }
        
        var stop = false
        
        let dataSource = currentFilter ?? self
        
        for i in 0..<numberOfSections() {
            for j in 0..<numberOfItems(inSection: i) {
                let indexPath = IndexPath(row: j, section: i)
                let item = dataSource.item(at: indexPath)
                
                itemBlock?(indexPath, item, &stop)
                
                if stop {
                    break
                }
            }
            
            if stop {
                break
            }
        }
    }
    
    func reload() {
        tableView.reloadData()
        collectionView.reloadData()
        updateEmptyView()
    }
    
    // MARK: - Empty View
    
    func updateEmptyView() {
        if let emptyView = emptyView {
            emptyView.isHidden = numberOfItems() != 0
        }
        
        if tableView != nil {
            let isEmpty = numberOfItems() == 0
            let shouldHideSeparators = isEmpty && cachedSeparatorStyle != .none
            
            if shouldHideSeparators {
                cachedSeparatorStyle = tableView.separatorStyle
                tableView.separatorStyle = .none
            } else if !shouldHideSeparators && cachedSeparatorStyle != .none {
                tableView.separatorStyle = cachedSeparatorStyle
                cachedSeparatorStyle = .none
            }
        }
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
        let identifier = NSStringFromClass(cellClass)
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
        
        let item = self.item(at: indexPath)
        configureCell(cell, for: item, parentView: tableView, indexPath: indexPath)
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return numberOfSections()
    }
    
    // MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItems(inSection: section)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let identifier = NSStringFromClass(cellClass)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath)
        
        let item = self.item(at: indexPath)
        configureCell(cell, for: item, parentView: collectionView, indexPath: indexPath)
        
        return cell
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }
}

