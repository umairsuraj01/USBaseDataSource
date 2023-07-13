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

import UIKit

class USSectionedDataSource: USBaseDataSource {
    var shouldRemoveEmptySections = true
    var sections: [USSection] = []
    
    override init() {
        super.init()
        sections = []
        shouldRemoveEmptySections = true
    }
    
    convenience init(items: [Any]?) {
        self.init()
        if let items = items, !items.isEmpty {
            let section = USSection.sectionWithItems(items)
            appendSection(newSection: section)
        }
    }
    
    convenience init(section: USSection?) {
        self.init()
        if let section = section {
            appendSection(newSection: section)
        }
    }
    
    convenience init(sections: [USSection]) {
        self.init()
        if !sections.isEmpty {
            insertSections(newSections: sections, atIndexes: IndexSet(integersIn: 0..<sections.count))
        }
    }
    
    override func numberOfSections() -> Int {
        return sections.count
    }
    
    override func numberOfItems(inSection section: Int) -> Int {
        return sectionAtIndex(index: section).numberOfItems()
    }
    
    override func item(at indexPath: IndexPath) -> Any {
        return sectionAtIndex(index: indexPath.section).itemAtIndex(indexPath.row) as Any
    }
    
    private func section(at index: Int) -> USSection {
        return sections[index]
    }
    
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
        insertCells(at: Self.indexPathArray(with: indexes, inSection: section))
    }
    
    func appendItems(items: [Any], toSection section: Int) {
        let sectionCount = numberOfItems(inSection: section)
        sectionAtIndex(index: section).items.addObjects(from: items)
        insertCells(at: Self.indexPathArray(with: NSMakeRange(sectionCount, items.count), inSection: section))
    }
    
    // MARK: - Adjusting sections
    
    func adjustSection(at index: Int, toNumberOfItems numberOfItems: Int) -> Bool {
        if numberOfItems == numberOfItems(inSection: index) {
            return false
        }
        
        if numberOfItems == 0 && shouldRemoveEmptySections {
            removeSection(at: index)
            return true
        }
        
        let section = sectionAtIndex(index: index)
        
        if numberOfItems > section.numberOfItems() {
            for i in section.numberOfItems()..<numberOfItems {
                section.items.insert(i as NSNumber, at: i)
            }
        } else {
            let range = numberOfItems..<section.numberOfItems()
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
        sectionAtIndex(index: section).items.removeObjects(at: indexes)
        
        if shouldRemoveEmptySections && numberOfItemsInSection(section: section) == 0 {
            removeSection(at: section)
        } else {
            deleteCells(at: Self.indexPathArray(with: indexes, inSection: section))
        }
    }
    
    func headerFooterView(withClass someClass: AnyClass) -> USBaseHeaderFooterView? {
        let identifier = String(describing: someClass.identifier())
        let headerFooterView = tableView?.dequeueReusableHeaderFooterView(withIdentifier: identifier) as? USBaseHeaderFooterView
        
        if headerFooterView == nil {
            return (someClass as? USBaseHeaderFooterView.Type)?.init(reuseIdentifier: identifier)
        }
        return headerFooterView
    }
    
    func viewForHeaderInSection(_ section: Int) -> USBaseHeaderFooterView? {
        return headerFooterView(withClass: sectionAtIndex(index: section).headerClass)
    }
    
    func viewForFooterInSection(_ section: Int) -> USBaseHeaderFooterView? {
        return headerFooterView(withClass: sectionAtIndex(index: section).footerClass)
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
        let item = item(at: sourceIndexPath)
        
        let sourceSection = sectionAtIndex(index: sourceIndexPath.section)
        let destinationSection = sectionAtIndex(index: destinationIndexPath.section)
        
        sourceSection.items.removeObject(at: sourceIndexPath.row)
        destinationSection.items.insert(item, at: destinationIndexPath.row)
    }
}

