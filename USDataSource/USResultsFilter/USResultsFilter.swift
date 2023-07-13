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
import UIKit

class USResultsFilter: NSObject, USDataSourceItemAccess {
    var filterPredicate: NSPredicate?
    var sections: NSMutableArray = []
    
    override init() {
        super.init()
        sections = []
    }
    
    static func filter(with predicate: NSPredicate) -> USResultsFilter? {
        let filter = USResultsFilter()
        filter.filterPredicate = predicate
        return filter
    }
    
    class func filter(with filterBlock: ((Any) -> Bool)?) -> USResultsFilter? {
        guard let filterBlock = filterBlock else {
            return nil
        }
        
        return self.filter(with: NSPredicate { object, _ in
            return filterBlock(object as Any)
        })
    }
    
    // MARK: - Item access
    
    func item(at indexPath: IndexPath) -> Any? {
        guard indexPath.section < sections.count else {
            return nil
        }
        let section = sections[indexPath.section]
        
        guard let items = section as? [Any], indexPath.row < items.count else {
            return nil
        }
        return items[indexPath.row]
    }
    
    func indexPath(for item: Any) -> IndexPath? {
        for (sectionIndex, section) in sections.enumerated() {
            guard let items = section as? [Any] else {
                continue
            }
            
            if let rowIndex = items.firstIndex(where: { ($0 as AnyObject).isEqual(item) }) {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
    }
    
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfItems(inSection section: Int) -> Int {
        guard section < sections.count, let items = sections[section] as? [Any] else {
            return 0
        }
        return items.count
    }
    
    func numberOfItems() -> Int {
        return sections.reduce(0) { (result, section) in
            if let items = section as? [Any] {
                return result + items.count
            }
            return result
        }
    }
}

