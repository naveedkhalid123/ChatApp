//
//  LoadingView.swift
//  ChatApp
//
//  Created by Naveed Khalid on 18/10/2025.
//

import UIKit

class LoadingView: UIView {

    @IBOutlet var containerView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initSubviews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        initSubviews()
    }
    
    func initSubviews(){
        let nib = UINib(nibName: "LoadingView", bundle: nil)
        nib.instantiate(withOwner: self)
        containerView.frame = bounds
        containerView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        addSubview(containerView)
    }
}
