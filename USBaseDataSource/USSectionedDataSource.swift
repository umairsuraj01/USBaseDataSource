//
//  USSectionedDataSource.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import UIKit

class USSectionedDataSource: USBaseDataSource, UITableViewDataSource {
    var shouldRemoveEmptySections = true
    var sections: [USSection] = []
    
    // MARK: - Section access
    
    func sectionAtIndex(index: Int) -> USSection {
        return sections[index]
    }
    
    func sectionWithIdentifier(identifier: Any) -> USSection? {
        if let index = indexOfSectionWithIdentifier(identifier: identifier) {
            return sectionAtIndex(index: index)
        }
        return nil
    }
    
    func indexOfSectionWithIdentifier(identifier: Any) -> Int? {
        return sections.firstIndex { $0.sectionIdentifier == identifier }
    }
    
    // MARK: - Moving sections
    
    func moveSectionAtIndex(fromIndex: Int, toIndex: Int) {
        let section = sections[fromIndex]
        sections.remove(at: fromIndex)
        sections.insert(section, at: toIndex)
        super.moveSectionAtIndex(fromIndex: fromIndex, toIndex: toIndex)
    }
    
    // MARK: - Inserting sections
    
    func appendSection(newSection: USSection) {
        insertSection(newSection: newSection, atIndex: numberOfSections())
    }
    
    func insertSection(newSection: USSection, atIndex index: Int) {
        sections.insert(newSection, at: index)
        insertSectionsAtIndexes(indexes: IndexSet(integer: index))
    }
    
    func insertSections(newSections: [USSection], atIndexes indexes: IndexSet) {
        var mutableSections: [USSection] = []
        
        newSections.forEach { sectionObject in
            if let section = sectionObject as? USSection {
                mutableSections.append(section)
            } else if let items = sectionObject as? [Any] {
                mutableSections.append(USSection(items: items))
            }
        }
        
        sections.insert(contentsOf: mutableSections, at: indexes.first ?? 0)
        insertSectionsAtIndexes(indexes: indexes)
    }
    
    // MARK: - Inserting items
    
    func insertItem(item: Any, at indexPath: IndexPath) {
        sectionAtIndex(index: indexPath.section).items.insert(item, at: indexPath.row)
        insertCellsAtIndexPaths(indexPaths: [indexPath])
    }
    
    func replaceItemAtIndexPath(indexPath: IndexPath, withItem item: Any) {
        sectionAtIndex(index: indexPath.section).items[indexPath.row] = item
        reloadCellsAtIndexPaths(indexPaths: [indexPath])
    }
    
    func insertItems(items: [Any], atIndexes indexes: IndexSet, inSection section: Int) {
        sectionAtIndex(index: section).items.insert(contentsOf: items, at: indexes.first ?? 0)
        insertCellsAtIndexPaths(indexPaths: USSectionedDataSource.indexPathArrayWithIndexSet(indexSet: indexes, inSection: section))
    }
    
    func appendItems(items: [Any], toSection section: Int) {
        let sectionCount = numberOfItemsInSection(section: section)
        sectionAtIndex(index: section).items.append(contentsOf: items)
        insertCellsAtIndexPaths(indexPaths: USSectionedDataSource.indexPathArrayWithRange(range: NSMakeRange(sectionCount, items.count), inSection: section))
    }
    
    // MARK: - Adjusting sections
    
    func adjustSectionAtIndex(index: Int, toNumberOfItems numberOfItems: Int) -> Bool {
        guard numberOfItemsInSection(section: index) != numberOfItems else {
            return false
        }
        
        let section = sectionAtIndex(index: index)
        
        if numberOfItems == 0 && shouldRemoveEmptySections {
            removeSectionAtIndex(index: index)
            return true
        }
        
        section.items = Array(section.items[0..<numberOfItems])
        reloadSectionAtIndex(index: index)
        return true
    }
    
    func removeSectionAtIndex(index: Int) {
        sections.remove(at: index)
        removeSectionsAtIndexes(indexes: IndexSet(integer: index))
    }
    
    // MARK: - UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItemsInSection(section: section)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sectionAtIndex(index: indexPath.section)
        let item = section.items[indexPath.row]
        
        if let cellIdentifier = section.cellIdentifier {
            let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
            // Configure the cell with the item
            return cell
        } else {
            // Create and configure the cell with the item
            return UITableViewCell()
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionAtIndex(index: section).headerTitle
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionAtIndex(index: section).footerTitle
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceSection = sectionAtIndex(index: sourceIndexPath.section)
        let item = sourceSection.items[sourceIndexPath.row]
        
        sourceSection.items.remove(at: sourceIndexPath.row)
        
        let destinationSection = sectionAtIndex(index: destinationIndexPath.section)
        destinationSection.items.insert(item, at: destinationIndexPath.row)
        
        moveCellAtIndexPath(indexPath: sourceIndexPath, toIndexPath: destinationIndexPath)
    }
    
    // Helper method to calculate the number of items in a section
    private func numberOfItemsInSection(section: Int) -> Int {
        return sectionAtIndex(index: section).items.count
    }
    
    // Helper method to generate an array of index paths from an index set and section number
    private static func indexPathArrayWithIndexSet(indexSet: IndexSet, inSection section: Int) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        
        indexSet.forEach { index in
            indexPaths.append(IndexPath(row: index, section: section))
        }
        
        return indexPaths
    }
    
    // Helper method to generate an array of index paths from a range and section number
    private static func indexPathArrayWithRange(range: NSRange, inSection section: Int) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        
        for i in range.location..<range.location + range.length {
            indexPaths.append(IndexPath(row: i, section: section))
        }
        
        return indexPaths
    }
}

