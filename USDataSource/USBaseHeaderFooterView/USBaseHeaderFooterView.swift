//
//  USBaseHeaderFooterView.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import UIKit

class USBaseHeaderFooterView: UITableViewHeaderFooterView {
    @objc static func identifier() -> String {
        return String(describing: self)
    }
    
    required override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func configureView(for dataSource: Any) {
        // Override this method to configure the view based on the provided data source
    }
}



