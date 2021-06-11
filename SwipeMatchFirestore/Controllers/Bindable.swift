//
//  Bindable.swift
//  SwipeMatchFirestore
//
//  Created by Ahmed Essmat on 31/03/2021.
//

import UIKit

class Bindable<T> {
    var value: T? {
        didSet {
            observer?(value)
        }
    }
    
    var observer: ((T?)->())?
    
    func bind(observer: @escaping(T?) -> ()) {
        self.observer = observer
    }
}
