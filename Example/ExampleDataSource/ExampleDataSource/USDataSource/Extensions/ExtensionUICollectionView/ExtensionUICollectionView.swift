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

extension UICollectionView {
    private struct AssociatedKeys {
        static var deletedSectionIndexes = "deletedSectionIndexes"
        static var insertedSectionIndexes = "insertedSectionIndexes"
        static var deletedItemIndexPaths = "deletedItemIndexPaths"
        static var insertedItemIndexPaths = "insertedItemIndexPaths"
        static var updatedItemIndexPaths = "updatedItemIndexPaths"
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
    
    private var deletedItemIndexPaths: NSMutableArray {
        get {
            guard let indexPaths = objc_getAssociatedObject(self, &AssociatedKeys.deletedItemIndexPaths) as? NSMutableArray else {
                let indexPaths = NSMutableArray()
                objc_setAssociatedObject(self, &AssociatedKeys.deletedItemIndexPaths, indexPaths, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return indexPaths
            }
            return indexPaths
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.deletedItemIndexPaths, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var insertedItemIndexPaths: NSMutableArray {
        get {
            guard let indexPaths = objc_getAssociatedObject(self, &AssociatedKeys.insertedItemIndexPaths) as? NSMutableArray else {
                let indexPaths = NSMutableArray()
                objc_setAssociatedObject(self, &AssociatedKeys.insertedItemIndexPaths, indexPaths, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return indexPaths
            }
            return indexPaths
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.insertedItemIndexPaths, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private var updatedItemIndexPaths: NSMutableArray {
        get {
            guard let indexPaths = objc_getAssociatedObject(self, &AssociatedKeys.updatedItemIndexPaths) as? NSMutableArray else {
                let indexPaths = NSMutableArray()
                objc_setAssociatedObject(self, &AssociatedKeys.updatedItemIndexPaths, indexPaths, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
                return indexPaths
            }
            return indexPaths
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.updatedItemIndexPaths, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    func addChange(for sectionInfo: NSFetchedResultsSectionInfo, at sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            insertedSectionIndexes.add(sectionIndex)
        case .delete:
            deletedSectionIndexes.add(sectionIndex)
            
            let indexPathsInSection = deletedItemIndexPaths.filter { ($0 as? IndexPath)?.section == sectionIndex }
            deletedItemIndexPaths.removeObjects(in: indexPathsInSection)
            
            let updatedIndexPathsInSection = updatedItemIndexPaths.filter { ($0 as? IndexPath)?.section == sectionIndex }
            updatedItemIndexPaths.removeObjects(in: updatedIndexPathsInSection)
            
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
            insertedItemIndexPaths.add(newIndexPath as Any)
            
        case .delete:
            if deletedSectionIndexes.contains(indexPath.section) {
                return
            }
            deletedItemIndexPaths.add(indexPath as Any)
            
        case .move:
            if !insertedSectionIndexes.contains(newIndexPath?.section ?? 0) {
                insertedItemIndexPaths.add(newIndexPath as Any)
            }
            if !deletedSectionIndexes.contains(indexPath.section) {
                deletedItemIndexPaths.add(indexPath as Any)
            }
            
        case .update:
            if deletedSectionIndexes.contains(indexPath.section) || deletedItemIndexPaths.contains(indexPath) {
                return
            }
            if !updatedItemIndexPaths.contains(indexPath) {
                updatedItemIndexPaths.add(indexPath as Any)
            }
            
        @unknown default:
            break
        }
    }
    
    func commitChanges(completion: @escaping (Bool) -> Void) {
        if self.window == nil {
            clearChanges()
            reloadData()
        } else {
            let totalChanges = deletedSectionIndexes.count + insertedSectionIndexes.count + deletedItemIndexPaths.count + insertedItemIndexPaths.count + updatedItemIndexPaths.count
            
            if totalChanges > 50 {
                clearChanges()
                reloadData()
                return
            }
            
            let deletedSectionChanges = deletedSectionIndexes.copy() as! IndexSet
            let insertedSectionChanges = insertedSectionIndexes.copy() as! IndexSet
            let deletedItemIndexPathsChanges = deletedItemIndexPaths.copy() as! [IndexPath]
            let insertedItemIndexPathsChanges = insertedItemIndexPaths.copy() as! [IndexPath]
            let updatedItemIndexPathsChanges = updatedItemIndexPaths.copy() as! [IndexPath]
            
            clearChanges()
            
            performBatchUpdates({
                deleteSections(deletedSectionChanges)
                insertSections(insertedSectionChanges)
                
                deleteItems(at: deletedItemIndexPathsChanges)
                insertItems(at: insertedItemIndexPathsChanges)
                reloadItems(at: updatedItemIndexPathsChanges)
            }, completion: { finished in
                self.clearChanges()
                completion(finished)
            })
        }
    }
    
    private func clearChanges() {
        deletedSectionIndexes.removeAllIndexes()
        insertedSectionIndexes.removeAllIndexes()
        deletedItemIndexPaths.removeAllObjects()
        insertedItemIndexPaths.removeAllObjects()
        updatedItemIndexPaths.removeAllObjects()
    }
}

