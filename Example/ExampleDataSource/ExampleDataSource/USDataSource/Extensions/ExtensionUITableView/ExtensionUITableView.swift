//
//  ExtensionUITableView.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 07/07/2023.
//

import UIKit
import CoreData

extension UITableView {
    private struct AssociatedKeys {
        static var deletedSectionIndexes = "deletedSectionIndexes"
        static var insertedSectionIndexes = "insertedSectionIndexes"
        static var deletedRowIndexPaths = "deletedRowIndexPaths"
        static var insertedRowIndexPaths = "insertedRowIndexPaths"
        static var updatedRowIndexPaths = "updatedRowIndexPaths"
    }
    
    private var deletedSectionIndexes: NSMutableIndexSet {
        get {
            guard let indexes = objc_getAssociatedObject(self, &AssociatedKeys.deletedSectionIndexes) as? NSMutableIndexSet else {
                let indexes = NSMutableIndexSet()
                objc_setAssociatedObject(self, &AssociatedKeys.deletedSectionIndexes, indexes, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return indexes
            }
            return indexes
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.deletedSectionIndexes, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var insertedSectionIndexes: NSMutableIndexSet {
        get {
            guard let indexes = objc_getAssociatedObject(self, &AssociatedKeys.insertedSectionIndexes) as? NSMutableIndexSet else {
                let indexes = NSMutableIndexSet()
                objc_setAssociatedObject(self, &AssociatedKeys.insertedSectionIndexes, indexes, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return indexes
            }
            return indexes
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.insertedSectionIndexes, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var deletedRowIndexPaths: NSMutableArray {
        get {
            guard let indexPaths = objc_getAssociatedObject(self, &AssociatedKeys.deletedRowIndexPaths) as? NSMutableArray else {
                let indexPaths = NSMutableArray()
                objc_setAssociatedObject(self, &AssociatedKeys.deletedRowIndexPaths, indexPaths, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return indexPaths
            }
            return indexPaths
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.deletedRowIndexPaths, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var insertedRowIndexPaths: NSMutableArray {
        get {
            guard let indexPaths = objc_getAssociatedObject(self, &AssociatedKeys.insertedRowIndexPaths) as? NSMutableArray else {
                let indexPaths = NSMutableArray()
                objc_setAssociatedObject(self, &AssociatedKeys.insertedRowIndexPaths, indexPaths, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return indexPaths
            }
            return indexPaths
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.insertedRowIndexPaths, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var updatedRowIndexPaths: NSMutableArray {
        get {
            guard let indexPaths = objc_getAssociatedObject(self, &AssociatedKeys.updatedRowIndexPaths) as? NSMutableArray else {
                let indexPaths = NSMutableArray()
                objc_setAssociatedObject(self, &AssociatedKeys.updatedRowIndexPaths, indexPaths, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return indexPaths
            }
            return indexPaths
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.updatedRowIndexPaths, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addChange(for sectionInfo: NSFetchedResultsSectionInfo, at sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSectionIndexes.add(sectionIndex)
        case .delete:
            deletedSectionIndexes.add(sectionIndex)
            
            let indexPathsInSection = deletedRowIndexPaths.filter { ($0 as? IndexPath)?.section == sectionIndex }
            deletedRowIndexPaths.removeObjects(in: indexPathsInSection)
            
        default:
            break
        }
    }
    
    func addChange(forObjectAt indexPath: IndexPath, forChangeType type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            if insertedSectionIndexes.contains(newIndexPath?.section ?? 0) {
                return
            }
            insertedRowIndexPaths.add(newIndexPath as Any)
            
        case .delete:
            if deletedSectionIndexes.contains(indexPath.section) {
                return
            }
            deletedRowIndexPaths.add(indexPath as Any)
            
        case .move:
            if !insertedSectionIndexes.contains(newIndexPath?.section ?? 0) {
                insertedRowIndexPaths.add(newIndexPath as Any)
            }
            if !deletedSectionIndexes.contains(indexPath.section) {
                deletedRowIndexPaths.add(indexPath as Any)
            }
            
        case .update:
            updatedRowIndexPaths.add(indexPath as Any)
            
        @unknown default:
            break
        }
    }
    
    func commitChanges(completion: @escaping (Bool) -> Void) {
        if self.window == nil {
            clearChanges()
            reloadData()
            return
        }
        
        let totalChanges = deletedSectionIndexes.count + insertedSectionIndexes.count + deletedRowIndexPaths.count + insertedRowIndexPaths.count + updatedRowIndexPaths.count
        
        if totalChanges > 50 {
            clearChanges()
            reloadData()
            return
        }
        
        beginUpdates()
        
        deleteSections(deletedSectionIndexes as IndexSet, with: .automatic)
        insertSections(insertedSectionIndexes as IndexSet, with: .automatic)
        
        deleteRows(at: deletedRowIndexPaths as! [IndexPath], with: .left)
        insertRows(at: insertedRowIndexPaths as! [IndexPath], with: .right)
        reloadRows(at: updatedRowIndexPaths as! [IndexPath], with: .none)
        
        endUpdates()
        clearChanges()
        completion(true)
    }
    
    private func clearChanges() {
        deletedSectionIndexes.removeAllIndexes()
        insertedSectionIndexes.removeAllIndexes()
        deletedRowIndexPaths.removeAllObjects()
        insertedRowIndexPaths.removeAllObjects()
        updatedRowIndexPaths.removeAllObjects()
    }
}
