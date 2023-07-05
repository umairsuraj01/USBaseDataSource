//
//  USBaseHeaderFooterView.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import UIKit

class USBaseHeaderFooterView: UITableViewHeaderFooterView {
    static func identifier() -> String {
        return String(describing: self)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    convenience init() {
        self.init(reuseIdentifier: type(of: self).identifier())
    }
    
    func configureView(for dataSource: Any) {
        // override me.
    }
}

