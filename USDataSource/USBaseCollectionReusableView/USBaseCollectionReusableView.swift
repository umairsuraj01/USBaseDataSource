//
//  USBaseCollectionReusableView.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import UIKit

class USBaseCollectionReusableView: UICollectionReusableView {
    static func identifier() -> String {
        return NSStringFromClass(self)
    }
    
    static func supplementaryView(for collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> Self {
        return collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: self.identifier(), for: indexPath) as! Self
    }
    
    func configureCell(_ cell: Any, at index: IndexPath, withObject object: Any) {
        // Implementation for configuring the cell goes here
    }
}

