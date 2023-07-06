//
//  USSection.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

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
    
    var numberOfItems: Int {
        return items.count
    }
    
    func itemAtIndex(_ index: Int) -> Any? {
        guard index < numberOfItems else {
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
    private(set) var isExpanded: Bool = true
    
    
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

