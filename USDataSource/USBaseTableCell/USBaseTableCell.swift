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

class USBaseTableCell: UITableViewCell {
    
    typealias USCollectionCellDidSelectBlock = (Any?, Any?, IndexPath?) -> Void
    typealias USRefreshParentTableView = (Any?, Any?, IndexPath?) -> Void
    
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
    
    class func identifier() -> String {
        return String(describing: self)
    }
    
    class func cellStyle() -> UITableViewCell.CellStyle {
        return .default
    }
    
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
    
    var collectionCellDidSelectBlock: USCollectionCellDidSelectBlock?
    var refreshParentTableView: USRefreshParentTableView?
    
    @IBAction func didTapButton(_ sender: Any?) {
        didTapTableButtonBlock?(sender)
    }
}

