//Copyright (c) 2023 Muhammad Umair Soorage
//Fantasy Tech Solutions
//
//Permission is hereby granted, free of charge, to any person obtaining
//a copy of this software and associated documentation files (the
//"Software"), to deal in the Software without restriction, including
//without limitation the rights to use, copy, modify, merge, publish,
//distribute, sublicense, and/or sell copies of the Software, and to
//permit persons to whom the Software is furnished to do so, subject to
//the following conditions:
//
//The above copyright notice and this permission notice shall be
//included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
//MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
//LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
//OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
//WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation

class USExpandingDataSource: USSectionedDataSource {
    
    typealias USCollapsedSectionCountBlock = (USSection, Int) -> Int
    
    var collapsedSectionCountBlock: USCollapsedSectionCountBlock?
    
    // MARK: - Section/Index helpers
    
    func isSectionExpanded(at index: Int) -> Bool {
        return sectionAtIndex(index: index).isExpanded
    }
    
    func isItemVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.row < numberOfItems(inSection: indexPath.section)
    }
    
    func expandedSectionIndexes() -> IndexSet {
        var expandedIndexes = IndexSet(integersIn: 0..<numberOfSections())
        
        sections.enumerated().forEach { index, section in
            if !section.isExpanded {
                expandedIndexes.remove(index)
            }
        }
        
        return expandedIndexes
    }
    
    func numberOfCollapsedRows(inSection sectionIndex: Int) -> Int {
        if let collapsedSectionCountBlock = collapsedSectionCountBlock {
            let section = sectionAtIndex(index: sectionIndex)
            return collapsedSectionCountBlock(section, sectionIndex)
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
        
        let section = sectionAtIndex(index: index)
        
        let targetRowCount = expanded ? section.numberOfItems() : numberOfCollapsedRows(inSection: index)
        let currentRowCount = numberOfItems(inSection: index)
        
        section.isExpanded = expanded
        
        if expanded {
            let indexPaths = IndexPath.array(withRange: NSMakeRange(currentRowCount, targetRowCount - currentRowCount), inSection: index)
            insertCells(at: indexPaths)
        } else {
            let indexPaths = IndexPath.array(withRange: NSMakeRange(targetRowCount, currentRowCount - targetRowCount), inSection: index)
            deleteCells(at: indexPaths)
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
        let itemCount = sectionAtIndex(index: section).numberOfItems()
        let indexes = IndexSet(integersIn: itemCount..<(itemCount + items.count))
        insertItems(items, atIndexes: indexes, inSection: section)
    }
    
    func insertItems(_ items: [Any], atIndexes indexes: IndexSet, inSection sectionIndex: Int) {
        let section = sectionAtIndex(index: sectionIndex)
        
        section.items.insert(items, at: indexes)
        
        let potentialIndexes = IndexPath.array(withIndexSet: indexes, inSection: sectionIndex)
        
        performBatchUpdates {
            potentialIndexes.forEach { indexPath in
                if isItemVisible(at: indexPath) {
                    insertCells(at: [indexPath])
                }
            }
        }
    }
    
    // MARK: - Replacing
    
    func replaceItem(at indexPath: IndexPath, with item: Any) {
        let section = sectionAtIndex(index: indexPath.section)
        
        section.items.removeObject(at: indexPath.row)
        section.items.insert(item, at: indexPath.row)
        
        if isItemVisible(at: indexPath) {
            reloadCells(at: [indexPath])
        }
    }
    
    // MARK: - Removing
    
    override func removeItem(at indexPath: IndexPath) {
        removeItems(atIndexes: IndexSet(integer: indexPath.row), inSection: indexPath.section)
    }
    
    func removeItems(in range: NSRange, inSection section: Int) {
        removeItems(atIndexes: IndexSet(integersIn: range.location..<NSMaxRange(range)), inSection: section)
    }
    
    func removeItems(atIndexes indexes: IndexSet, inSection sectionIndex: Int) {
        let section = sectionAtIndex(index: sectionIndex)
        
        section.items.removeObjects(at: indexes)
        
        if shouldRemoveEmptySections && section.numberOfItems() == 0 {
            removeSection(at: sectionIndex)
        } else {
            let potentialIndexes = IndexPath.array(withIndexSet: indexes, inSection: sectionIndex)
            
            performBatchUpdates {
                potentialIndexes.forEach { indexPath in
                    if isItemVisible(at: indexPath) {
                        deleteCells(at: [indexPath])
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
    
    static func array(withIndexSet indexSet: IndexSet, inSection sectionIndex: Int) -> [IndexPath] {
        return indexSet.map { IndexPath(row: $0, section: sectionIndex) }
    }
}

