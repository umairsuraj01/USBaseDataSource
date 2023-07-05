//
//  USCoreDataSource.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import UIKit
import CoreData

/**
 * Generic table/collectionview data source, useful when your data comes from an NSFetchedResultsController.
 * Automatically inserts/reloads/deletes rows in the table or collection view in response to FRC events.
 */
class USCoreDataSource: USBaseDataSource, NSFetchedResultsControllerDelegate {
    
    // MARK: Properties
    
    /// The data source's fetched results controller. You probably don't need to set this directly as both initializers will do this for you.
    var controller: NSFetchedResultsController<NSFetchRequestResult>?
    
    /// Any error experienced during the most recent fetch. nil if the fetch succeeded.
    private(set) var fetchError: Error?
    
    // Block called when move is needed on a CoreData object.
    typealias USCoreDataMoveRowBlock = (Any, IndexPath, IndexPath) -> Void
    var coreDataMoveRowBlock: USCoreDataMoveRowBlock?
    
    // Block called after performFetch.
    typealias USCoreDataPostReloadBlock = (Any, UIView) -> Void
    var coreDataPostReloadBlock: USCoreDataPostReloadBlock?
    
    // Block called to configure each table and collection cell.
    typealias USTitleForHeaderConfigureBlock = (Any, UIView, Int) -> Any
    var titleForHeaderConfigureBlock: USTitleForHeaderConfigureBlock?
    
    // Block called to configure each table and collection cell.
    typealias USsectionIndexTitlesConfigureBlock = (Any, UIView) -> Any
    var sectionIndexTitlesConfigureBlock: USsectionIndexTitlesConfigureBlock?
    
    // For UICollectionView
    private var lastFilter: USResultsFilter?
    
    var reloadCollectionViewAfterChanges = false
    
    // MARK: Initializers
    
    init() {
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
    
    func numberOfSections() -> Int {
        return currentFilter?.numberOfSections() ?? controller?.sections?.count ?? 0
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        if let currentFilter = currentFilter {
            return currentFilter.numberOfItems(inSection: section)
        } else if let sectionInfo = controller?.sections?[section] {
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    func numberOfItems() -> Int {
        if let currentFilter = currentFilter {
            return currentFilter.numberOfItems()
        } else {
            return controller?.sections?.reduce(0, { $0 + $1.numberOfObjects }) ?? 0
        }
    }
    
    func item(at indexPath: IndexPath) -> Any? {
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
            return sectionIndexTitlesConfigureBlock(controller, tableView) as? [String]
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
        lastFilter = currentFilter
        setCurrentFilter(nil)
        tableView?.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                    didChange anObject: Any,
                    at indexPath: IndexPath?,
                    for type: NSFetchedResultsChangeType,
                    newIndexPath: IndexPath?) {
        guard let tableView = self.tableView else { return }
        self.collectionView?.addChange(forObjectAt: indexPath, forChangeType: type, newIndexPath: newIndexPath)
        
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
        self.collectionView?.addChange(forSection: sectionInfo, atIndex: sectionIndex, forChangeType: type)
        
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
