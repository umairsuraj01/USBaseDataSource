//
//  USSectionedDataSource.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import UIKit

class USSectionedDataSource: USBaseDataSource {
    var shouldRemoveEmptySections = true
    var sections: [USSection] = []
    
    // MARK: - Section access
    
    func sectionAtIndex(index: Int) -> USSection {
        return sections[index]
    }
    
    func sectionWithIdentifier<T: Equatable>(identifier: T) -> USSection? {
        if let index = indexOfSectionWithIdentifier(identifier: identifier) {
            return sectionAtIndex(index: index)
        }
        return nil
    }
    
    func indexOfSectionWithIdentifier<T: Equatable>(identifier: T) -> Int? {
        return sections.firstIndex { $0.sectionIdentifier as! T == identifier }
    }

    
    // MARK: - Moving sections
    
    override func moveSection(at index1: Int, to index2: Int) {
        let section = sections[index1]
        sections.remove(at: index1)
        sections.insert(section, at: index2)
        super.moveSection(at: index1, to: index2)
    }
    
    // MARK: - Inserting sections
    
    func appendSection(newSection: USSection) {
        insertSection(newSection: newSection, atIndex: numberOfSections())
    }
    
    func insertSection(newSection: USSection, atIndex index: Int) {
        sections.insert(newSection, at: index)
        insertSections(at: IndexSet(integer: index))
    }
    
    func insertSections(newSections: [USSection], atIndexes indexes: IndexSet) {
        var mutableSections: [USSection] = []
        newSections.forEach { sectionObject in
            mutableSections.append(sectionObject)
        }
        sections.insert(contentsOf: mutableSections, at: indexes.first ?? 0)
        insertSections(at: indexes)
    }
    
    // MARK: - Inserting items
    
    func insertItem(item: Any, at indexPath: IndexPath) {
        sectionAtIndex(index: indexPath.section).items.insert(item, at: indexPath.row)
        insertCells(at: [indexPath])
    }
    
    func replaceItemAtIndexPath(indexPath: IndexPath, withItem item: Any) {
        sectionAtIndex(index: indexPath.section).items[indexPath.row] = item
        reloadCells(at: [indexPath])
    }
    
    func insertItems(items: [Any], atIndexes indexes: IndexSet, inSection section: Int) {
        sectionAtIndex(index: section).items.insert(items, at: indexes.first ?? 0)
        insertCells(at: USSectionedDataSource.indexPathArrayWithIndexSet(indexSet: indexes, inSection: section))
    }
    
    func appendItems(items: [Any], toSection section: Int) {
        let sectionCount = numberOfItemsInSection(section: section)
        sectionAtIndex(index: section).items.addObjects(from: items)
        insertCells(at: USSectionedDataSource.indexPathArrayWithRange(range: NSMakeRange(sectionCount, items.count), inSection: section))
    }
    
    // MARK: - Adjusting sections
    
    func adjustSection(at index: Int, toNumberOfItems numberOfItems: Int) -> Bool {
        if numberOfItems == numberOfItemsInSection(section: index) {
            return false
        }
        
        if numberOfItems == 0 && shouldRemoveEmptySections {
            removeSection(at: index)
            return true
        }
        
        let section = sectionAtIndex(index: index)
        
        if numberOfItems > section.numberOfItems {
            for i in section.numberOfItems..<numberOfItems {
                section.items.insert(i as NSNumber, at: i)
            }
        } else {
            let range = numberOfItems..<section.numberOfItems
                let indexesToRemove = IndexSet(integersIn: range)
                section.items.removeObjects(at: indexesToRemove)
        }
        
        reloadSections(at: IndexSet(integer: index))
        
        return true
    }

    
    func clearSections() {
        currentFilter = nil
        sections.removeAll()
        reloadData()
    }

    func removeAllSections() {
        clearSections()
    }

    func removeAllItems(in section: Int) {
        currentFilter = nil
        if sections.count > section {
            sections.remove(at: section)
            reloadData()
        }
    }

    func removeSection(at index: Int) {
        removeSections(at: IndexSet(integer: index))
    }
    
    func removeSections(in range: NSRange) {
        removeSections(at: IndexSet(integersIn: Range(range) ?? 0..<0))
    }

    
    func removeSections(at indexes: IndexSet) {
        let sortedIndexes = indexes.sorted().reversed()
        for index in sortedIndexes {
            sections.remove(at: index)
        }
        deleteSections(at: indexes)
    }

    
    func removeSection<T: Equatable>(withIdentifier identifier: T) {
        if let index = indexOfSectionWithIdentifier(identifier: identifier) {
            removeSection(at: index)
        }
    }

    func removeItem(at indexPath: IndexPath) {
        removeItems(at: IndexSet(integer: indexPath.row), in: indexPath.section)
    }
    
    func removeItems(in range: NSRange, in section: Int) {
        removeItems(at: IndexSet(integersIn: Range(range) ?? 0..<0), in: section)
    }

    func removeItems(at indexes: IndexSet, in section: Int) {
        sections[section].items.remove(indexes)
        
        if shouldRemoveEmptySections && numberOfItemsInSection(section: section) == 0 {
            removeSection(at: section)
        } else {
            deleteCells(at: USSectionedDataSource.indexPathArray(with: indexes, inSection: section))
        }
    }
    
//    func headerFooterView(withClass class: AnyClass) -> USBaseHeaderFooterView? {
//        let identifier = String(describing: `class`.identifier())
//        let headerFooterView = tableView?.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? USBaseHeaderFooterView
//
//        if headerFooterView == nil {
//            return `class`.init() as? USBaseHeaderFooterView
//        }
//
//        return headerFooterView
//    }

    func viewForHeaderInSection(_ section: Int) -> USBaseHeaderFooterView? {
        return nil
//        return headerFooterView(withClass: sectionAtIndex(index: section).headerClass)
    }

    func viewForFooterInSection(_ section: Int) -> USBaseHeaderFooterView? {
        return nil
//        return headerFooterView(withClass: sectionAtIndex(index: section).footerClass)
    }

    func heightForHeaderInSection(_ section: Int) -> CGFloat {
        return sectionAtIndex(index: section).headerHeight
    }

    func heightForFooterInSection(_ section: Int) -> CGFloat {
        return sectionAtIndex(index: section).footerHeight
    }

    func titleForHeaderInSection(_ section: Int) -> String? {
        return sectionAtIndex(index: section).header
    }

    func titleForFooterInSection(_ section: Int) -> String? {
        return sectionAtIndex(index: section).footer
    }

    
    // MARK: - UITableViewDataSource methods
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionAtIndex(index: section).header
    }
    
    func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionAtIndex(index: section).footer
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let sourceSection = sectionAtIndex(index: sourceIndexPath.section)
        let item = sourceSection.items[sourceIndexPath.row]
        
        sourceSection.items.remove(sourceIndexPath.row)
        
        let destinationSection = sectionAtIndex(index: destinationIndexPath.section)
        destinationSection.items.insert(item, at: destinationIndexPath.row)
        moveCell(at: sourceIndexPath, to: destinationIndexPath)
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

