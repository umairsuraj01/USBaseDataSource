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

