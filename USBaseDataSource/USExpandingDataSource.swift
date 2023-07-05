//
//  USExpandingDataSource.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import Foundation

class USExpandingDataSource: USSectionedDataSource {
    
    typealias USCollapsedSectionCountBlock = (USSection, Int) -> Int
    
    var collapsedSectionCountBlock: USCollapsedSectionCountBlock?
    
    // MARK: - Section/Index helpers
    
    func isSectionExpanded(at index: Int) -> Bool {
        return section(at: index)?.isExpanded ?? false
    }
    
    func isItemVisible(at indexPath: IndexPath) -> Bool {
        guard let section = section(at: indexPath.section) else {
            return false
        }
        
        let rowCount = numberOfItems(inSection: indexPath.section)
        let collapsedRowCount = numberOfCollapsedRows(inSection: indexPath.section)
        
        return indexPath.row < rowCount && indexPath.row < collapsedRowCount
    }
    
    func expandedSectionIndexes() -> IndexSet {
        let expandedIndexes = IndexSet(integersIn: 0..<numberOfSections)
        
        sections.enumerated().forEach { index, section in
            if !section.isExpanded {
                expandedIndexes.remove(index)
            }
        }
        
        return expandedIndexes
    }
    
    func numberOfCollapsedRows(inSection section: Int) -> Int {
        if let collapsedSectionCountBlock = collapsedSectionCountBlock,
           let section = section(at: section) {
            return collapsedSectionCountBlock(section, section)
        }
        
        return 0
    }
    
    // MARK: - Expanding Sections
    
    func toggleSection(at index: Int) {
        setSection(at: index, expanded: !isSectionExpanded(at: index))
    }
    
    func setSection(_ section: USSection, expanded: Bool) {
        guard let sectionIndex = sections.firstIndex(of: section) else {
            return
        }
        
        setSection(at: sectionIndex, expanded: expanded)
    }
    
    func setSection(at index: Int, expanded: Bool) {
        guard isSectionExpanded(at: index) != expanded else {
            return
        }
        
        guard let section = section(at: index) else {
            return
        }
        
        let targetRowCount = expanded ? section.numberOfItems : numberOfCollapsedRows(inSection: index)
        let currentRowCount = numberOfItems(inSection: index)
        
        section.expanded = expanded
        
        if expanded {
            let indexPaths = IndexPath.array(withRange: NSMakeRange(currentRowCount, targetRowCount - currentRowCount), inSection: index)
            insertCells(atIndexPaths: indexPaths)
        } else {
            let indexPaths = IndexPath.array(withRange: NSMakeRange(targetRowCount, currentRowCount - targetRowCount), inSection: index)
            deleteCells(atIndexPaths: indexPaths)
        }
    }
    
    // MARK: - USBaseDataSource
    
    override func numberOfItems(inSection section: Int) -> Int {
        let itemCount = super.numberOfItems(inSection: section)
        
        return isSectionExpanded(at: section) ? itemCount : min(itemCount, numberOfCollapsedRows(inSection: section))
    }
    
    // MARK: - Adding Items
    
    func insertItem(_ item: Any, at indexPath: IndexPath) {
        insertItems([item], atIndexes: IndexSet(integer: indexPath.row), inSection: indexPath.section)
    }
    
    func appendItems(_ items: [Any], toSection section: Int) {
        let itemCount = section(at: section)?.numberOfItems ?? 0
        let indexes = IndexSet(integersIn: itemCount..<(itemCount + items.count))
        insertItems(items, atIndexes: indexes, inSection: section)
    }
    
    func insertItems(_ items: [Any], atIndexes indexes: IndexSet, inSection section: Int) {
        guard let section = section(at: section) else {
            return
        }
        
        section.items.insert(items, atIndexes: indexes)
        
        let potentialIndexes = IndexPath.array(withIndexSet: indexes, inSection: section)
        
        performBatchUpdates {
            potentialIndexes.forEach { indexPath in
                if isItemVisible(at: indexPath) {
                    insertCells(atIndexPaths: [indexPath])
                }
            }
        }
    }
    
    // MARK: - Replacing
    
    func replaceItem(at indexPath: IndexPath, with item: Any) {
        guard let section = section(at: indexPath.section) else {
            return
        }
        
        section.items.removeObject(at: indexPath.row)
        section.items.insert(item, at: indexPath.row)
        
        if isItemVisible(at: indexPath) {
            reloadCells(atIndexPaths: [indexPath])
        }
    }
    
    // MARK: - Removing
    
    func removeItem(at indexPath: IndexPath) {
        removeItems(atIndexes: IndexSet(integer: indexPath.row), inSection: indexPath.section)
    }
    
    func removeItems(in range: NSRange, inSection section: Int) {
        removeItems(atIndexes: IndexSet(integersIn: range.location..<NSMaxRange(range)), inSection: section)
    }
    
    func removeItems(atIndexes indexes: IndexSet, inSection section: Int) {
        guard let section = section(at: section) else {
            return
        }
        
        section.items.removeObjects(atIndexes: indexes)
        
        if shouldRemoveEmptySections && section.numberOfItems == 0 {
            removeSection(at: section)
        } else {
            let potentialIndexes = IndexPath.array(withIndexSet: indexes, inSection: section)
            
            performBatchUpdates {
                potentialIndexes.forEach { indexPath in
                    if isItemVisible(at: indexPath) {
                        deleteCells(atIndexPaths: [indexPath])
                    }
                }
            }
        }
    }
    
    // MARK: - Internal
    
    private func performBatchUpdates(updates: () -> Void) {
        collectionView?.performBatchUpdates(updates, completion: nil)
        
        tableView?.beginUpdates()
        updates()
        tableView?.endUpdates()
    }
}

extension IndexPath {
    static func array(withRange range: NSRange, inSection section: Int) -> [IndexPath] {
        return (range.location..<NSMaxRange(range)).map { IndexPath(row: $0, section: section) }
    }
    
    static func array(withIndexSet indexSet: IndexSet, inSection section: USSection) -> [IndexPath] {
        return indexSet.map { IndexPath(row: $0, section: section.sectionIndex) }
    }
}

