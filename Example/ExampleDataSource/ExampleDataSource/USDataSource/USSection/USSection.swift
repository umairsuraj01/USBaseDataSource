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

class USSection: NSObject, NSCopying {
    
    override init() {
        super.init()
        items = []
        headerClass = USBaseHeaderFooterView.self
        footerClass = USBaseHeaderFooterView.self
        headerHeight = UITableView.automaticDimension
        footerHeight = UITableView.automaticDimension
        isExpanded = true
    }
    
    static func sectionWithItems(_ items: [Any]?) -> USSection {
        return sectionWithItems(items, header: nil, footer: nil, identifier: nil)
    }
    
    static func sectionWithItems(_ items: [Any]?, header: String?, footer: String?, identifier: Any?) -> USSection {
        let section = USSection()
        
        if let items = items {
            section.items.addObjects(from: items)
        }
        section.header = header
        section.footer = footer
        section.sectionIdentifier = identifier
        return section
    }
    
    static func sectionWithNumberOfItems(_ numberOfItems: UInt) -> Self {
        return sectionWithNumberOfItems(numberOfItems, header: nil, footer: nil, identifier: nil)
    }
    
    static func sectionWithNumberOfItems(_ numberOfItems: UInt, header: String?, footer: String?, identifier: Any?) -> Self {
        var array = [Any]()
        
        for i in 0..<numberOfItems {
            array.append(i)
        }
        return sectionWithItems(array, header: header, footer: footer, identifier: identifier) as! Self
    }
    
    func numberOfItems() -> Int {
        return items.count
    }
    
    func itemAtIndex(_ index: Int) -> Any? {
        guard index < numberOfItems() else {
            return nil
        }
        
        return items[Int(index)]
    }
    
    var items: NSMutableArray = NSMutableArray()
    var sectionIdentifier: Any?
    var header: String?
    var footer: String?
    var headerClass: AnyClass = USBaseHeaderFooterView.self
    var footerClass: AnyClass = USBaseHeaderFooterView.self
    var headerHeight: CGFloat = UITableView.automaticDimension
    var footerHeight: CGFloat = UITableView.automaticDimension
    var isExpanded: Bool = true
    
    
    class func identifier() -> String {
        return String(describing: self)
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let newSection = USSection.sectionWithItems(items.copy() as? [Any])
        newSection.header = header
        newSection.footer = footer
        newSection.headerClass = headerClass
        newSection.footerClass = footerClass
        newSection.headerHeight = headerHeight
        newSection.footerHeight = footerHeight
        newSection.sectionIdentifier = sectionIdentifier
        return newSection
    }
}

