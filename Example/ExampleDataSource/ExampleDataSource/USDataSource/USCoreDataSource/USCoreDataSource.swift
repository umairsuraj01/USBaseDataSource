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
import CoreData

class USCoreDataSource: USBaseDataSource, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    
    var controller: NSFetchedResultsController<NSFetchRequestResult>?
    
    private(set) var fetchError: Error?
    
    typealias USCoreDataMoveRowBlock = (Any, IndexPath, IndexPath) -> Void
    var coreDataMoveRowBlock: USCoreDataMoveRowBlock?
    
    typealias USCoreDataPostReloadBlock = (Any, UIView) -> Void
    var coreDataPostReloadBlock: USCoreDataPostReloadBlock?
    
    typealias USTitleForHeaderConfigureBlock = (Any, UIView, Int) -> Any
    var titleForHeaderConfigureBlock: USTitleForHeaderConfigureBlock?
    
    typealias USsectionIndexTitlesConfigureBlock = (Any, UIView) -> Any
    var sectionIndexTitlesConfigureBlock: USsectionIndexTitlesConfigureBlock?
    
    private var lastFilter: USResultsFilter?
    
    var reloadCollectionViewAfterChanges = false
    
    // MARK: Initializers
    
    override init() {
        super.init()
    }
    
    init(controller: NSFetchedResultsController<NSFetchRequestResult>) {
        self.controller = controller
        super.init()
        self.controller?.delegate = self
        
        if self.controller?.fetchedObjects == nil {
            _performFetch()
        }
    }
    
    init(fetchRequest: NSFetchRequest<NSFetchRequestResult>, context: NSManagedObjectContext, sectionNameKeyPath: String?) {
        let controller = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                    managedObjectContext: context,
                                                    sectionNameKeyPath: sectionNameKeyPath,
                                                    cacheName: nil)
        self.controller = controller
        super.init()
        self.controller?.delegate = self
        _performFetch()
    }
    
    deinit {
        controller?.delegate = nil
        controller = nil
        coreDataMoveRowBlock = nil
        titleForHeaderConfigureBlock = nil
    }
    
    // MARK: Fetching
    
    private func _performFetch() {
        do {
            try controller?.performFetch()
            fetchError = nil
        } catch {
            fetchError = error
        }
    }
    
    // MARK: USDataSourceItemAccess
    
    override func numberOfSections() -> Int {
        return currentFilter?.numberOfSections() ?? controller?.sections?.count ?? 0
    }
    
    override func numberOfItems(inSection section: Int) -> Int {
        if let currentFilter = currentFilter {
            return currentFilter.numberOfItems(inSection: section)
        } else if let sectionInfo = controller?.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    override func numberOfItems() -> Int {
        if let currentFilter = currentFilter {
            return currentFilter.numberOfItems()
        } else {
            return controller?.sections?.reduce(0, { $0 + $1.numberOfObjects }) ?? 0
        }
    }
    
    override func item(at indexPath: IndexPath) -> Any? {
        if let currentFilter = currentFilter {
            return currentFilter.item(at: indexPath)
        } else if let object = controller?.object(at: indexPath) {
            return object
        }
        return nil
    }
    
    // MARK: Core Data access
    
    func indexPath(forItemWithId objectId: NSManagedObjectID) -> IndexPath? {
        guard let sections = controller?.sections else {
            return nil
        }
        
        for section in 0..<sections.count {
            let sectionInfo = sections[section]
            if let objects = sectionInfo.objects as? [NSManagedObject],
               let index = objects.firstIndex(where: { $0.objectID == objectId }) {
                return IndexPath(row: index, section: section)
            }
        }
        
        return nil
    }
    
    // MARK: UITableViewDataSource
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return controller?.section(forSectionIndexTitle: title, at: index) ?? 0
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        if let sectionIndexTitlesConfigureBlock = sectionIndexTitlesConfigureBlock {
            return sectionIndexTitlesConfigureBlock(controller as Any, tableView) as? [String]
        } else {
            return controller?.sectionIndexTitles
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if let sectionInfo = controller?.sections?[section] {
            if let titleForHeaderConfigureBlock = titleForHeaderConfigureBlock {
                return titleForHeaderConfigureBlock(sectionInfo, tableView, section) as? String
            } else {
                return sectionInfo.name
            }
        }
        return nil
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        if let item = item(at: sourceIndexPath) {
            coreDataMoveRowBlock?(item, sourceIndexPath, destinationIndexPath)
        }
    }
    
    // MARK: NSFetchedResultsControllerDelegate
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView?.endUpdates()
        
        if let tableView = tableView {
            tableView.commitChanges { [weak self] _ in
                if let lastFilter = self?.lastFilter {
                    self?.setCurrentFilter(lastFilter)
                    self?.lastFilter = nil
                }
                // Hackish; force recalculation of empty view state
                self?.emptyView = self?.emptyView
                self?.coreDataPostReloadBlock?(self!, tableView)
            }
        }
        
        if reloadCollectionViewAfterChanges, let collectionView = collectionView {
            collectionView.commitChanges { [weak self] _ in
                if let lastFilter = self?.lastFilter {
                    self?.setCurrentFilter(lastFilter)
                    self?.lastFilter = nil
                }
                // Hackish; force recalculation of empty view state
                self?.emptyView = self?.emptyView
                self?.coreDataPostReloadBlock?(self!, collectionView)
            }
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        lastFilter = currentFilter as? USResultsFilter
        setCurrentFilter(nil)
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        guard let tableView = self.tableView else { return }
        guard indexPath != nil else {
            return
        }
        guard newIndexPath != nil else {
            return
        }
        self.collectionView?.addChange(forObjectAt: indexPath!, forChangeType: type, newIndexPath: newIndexPath)
        
        switch type {
        case .insert:
            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: self.rowAnimation)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: self.rowAnimation)
            }
        case .update:
            if let indexPath = indexPath {
                tableView.reloadRows(at: [indexPath], with: self.rowAnimation)
            }
        case .move:
            if let indexPath = indexPath, let newIndexPath = newIndexPath {
                tableView.deleteRows(at: [indexPath], with: self.rowAnimation)
                tableView.insertRows(at: [newIndexPath], with: self.rowAnimation)
            }
        @unknown default:
            break
        }
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange sectionInfo: NSFetchedResultsSectionInfo,
                    at sectionIndex: Int,
                    for type: NSFetchedResultsChangeType) {
        guard let tableView = self.tableView else { return }
        self.collectionView?.addChange(for: sectionInfo, at: sectionIndex, forChangeType: type)
        
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: self.rowAnimation)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: self.rowAnimation)
        default:
            return
        }
    }
}
