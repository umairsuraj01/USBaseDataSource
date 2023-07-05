//
//  USDataSourceItemAccess.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import Foundation

// Enumeration block for enumerating data source items.
typealias USDataSourceEnumerator = (IndexPath, Any, UnsafeMutablePointer<ObjCBool>) -> Void

protocol USDataSourceItemAccess {
    /**
     Return the item at a given index path. Override me in your subclass.
     */
    func item(at indexPath: IndexPath) -> Any
    
    /**
     Search the data source for the first instance of the specified item.
     Sends isEqual: to every item in the data source.
     
     - parameter item: an item to search for
     
     - returns: the item's index path if found, or nil
     */
    func indexPath(for item: Any) -> IndexPath?
    
    /**
     Return the total number of items in the data source. Override me in your subclass.
     */
    func numberOfItems() -> Int
    
    /**
     Return the total number of sections in the data source. Override me!
     */
    func numberOfSections() -> Int
    
    /**
     Return the total number of items in a given section. Override me!
     
     - parameter section: the section index
     
     - returns: the number of items in the section
     */
    func numberOfItems(inSection section: Int) -> Int
    
    /**
     Enumerate every item in the data source (or currently-active filter), executing a block for each item.
     
     - parameter itemBlock: block to execute for each item
     */
    func enumerateItems(with itemBlock: USDataSourceEnumerator)
}

extension USDataSourceItemAccess {
    /**
     Enumerate every item in the data source (or currently-active filter), executing a block for each item.
     
     - parameter itemBlock: block to execute for each item
     */
    func enumerateItems(with itemBlock: USDataSourceEnumerator) {
        let stop = UnsafeMutablePointer<ObjCBool>.allocate(capacity: 1)
        stop.pointee = false
        
        for section in 0..<numberOfSections() {
            let itemCount = numberOfItems(inSection: section)
            
            for itemIndex in 0..<itemCount {
                let indexPath = IndexPath(item: itemIndex, section: section)
                let item = self.item(at: indexPath)
                
                itemBlock(indexPath, item, stop)
                
                if stop.pointee {
                    break
                }
            }
            
            if stop.pointee {
                break
            }
        }
        
        stop.deallocate()
    }
}

