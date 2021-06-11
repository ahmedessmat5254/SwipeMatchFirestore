//
//  CustomTextField.swift
//  SwipeMatchFirestore
//
//  Created by Ahmed Essmat on 23/03/2021.
//

import UIKit

//Custom Text Field Class
class CustomTextField: UITextField, UITextFieldDelegate {
    
    let padding: CGFloat
    
    init(padding: CGFloat) {
        self.padding = padding
        super.init(frame: .zero)
        layer.cornerRadius = 22
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.insetBy(dx: padding, dy: 0)
    }
    override var intrinsicContentSize: CGSize {
        return .init(width: 0, height: 50)
    }

}
