//
//  USBaseTableCell.swift
//  USBaseDataSource
//
//  Created by Umair Suraj on 05/07/2023.
//

import UIKit

/**
 * A simple base table cell. Subclass me and override configureCell
 * to add custom one-time logic (e.g. creating subviews).
 * Override cellStyle to use a different style.
 * You probably don't need to override identifier.
 */

class USBaseTableCell: UITableViewCell {
    
    // Block called when embedded collection cell is selected.
    typealias USCollectionCellDidSelectBlock = (Any?, Any?, IndexPath?) -> Void
    typealias USRefreshParentTableView = (Any?, Any?, IndexPath?) -> Void
    
    /**
     * Dequeues a table cell from tableView, or if there are no cells of the
     * receiver's type in the queue, creates a new cell and calls -configureCell.
     */
    
    class func cellForTableView(_ tableView: UITableView) -> Self {
        var cell = tableView.dequeueReusableCell(withIdentifier: self.identifier()) as? Self
        
        if cell == nil {
            cell = self.init(style: self.cellStyle(), reuseIdentifier: self.identifier())
            cell?.configureCell()
        }
        
        return cell!
    }
    
    required override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configureCell()
    }
    
    /**
     *  Cell's identifier. You probably don't need to override me.
     *
     *  @return an identifier for this cell class
     */
    class func identifier() -> String {
        return String(describing: self)
    }
    
    /**
     *  Cell style to use. Override me in a subclass and return a different style.
     *
     *  @return cell style to use for this class
     */
    class func cellStyle() -> UITableViewCell.CellStyle {
        return .default
    }
    
    /**
     *  Called once for each cell after initial creation.
     *  Subclass me for one-time logic, like creating subviews.
     */
    func configureCell() {
        // override me!
    }
    
    func configureCell(_ cell: Any?, atIndex thisIndex: IndexPath?, withObject object: Any?) {
        
    }
    
    var didTapTableButtonBlock: ((Any?) -> Void)?
    var didTapShareButtonBlock: ((Any?) -> Void)?
    
    func setDidTapTableButtonBlock(_ didTapButtonBlock: ((Any?) -> Void)?) {
        didTapTableButtonBlock = didTapButtonBlock
    }
    
    func setDidTapShareButtonBlock(_ didTapShareButtonBlock: ((Any?) -> Void)?) {
        self.didTapShareButtonBlock = didTapShareButtonBlock
    }
    
    /**
     * Cell configuration block, called for each table and collection
     * cell with the object to display in that cell. See block signature above.
     */
    var collectionCellDidSelectBlock: USCollectionCellDidSelectBlock?
    var refreshParentTableView: USRefreshParentTableView?
    
    @IBAction func didTapButton(_ sender: Any?) {
        didTapTableButtonBlock?(sender)
    }
}

