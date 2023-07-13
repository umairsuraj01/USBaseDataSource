//
//  USBaseCollectionCell.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import UIKit

class USBaseCollectionCell: UICollectionViewCell {
    static func identifier() -> String {
        return String(describing: self)
    }
    
    static func cellForCollectionView(_ collectionView: UICollectionView, indexPath: IndexPath) -> Self {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: identifier(), for: indexPath) as! Self
        
        if !cell.didCompleteSetup {
            cell.configureCell()
            cell.didCompleteSetup = true
        }
        
        return cell
    }
    
    var didTapCollectionButtonBlock: ((Any) -> Void)?
    
    @IBAction func didTapButton(_ sender: Any) {
        didTapCollectionButtonBlock?(sender)
    }
    
    private var didCompleteSetup = false
    
    func configureCell() {
        // override me!
    }
    
    func configureCell(_ cell: Any, atIndex thisIndex: IndexPath, withObject object: Any) {
        // override me!
    }
}

