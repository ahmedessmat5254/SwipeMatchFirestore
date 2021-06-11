//
//  CardViewModel.swift
//  SwipeMatchFirestore
//
//  Created by Ahmed Essmat on 14/03/2021.
//

import UIKit


protocol ProducesCardViewModel {
    func toCardViewModel () -> CardViewModel
}
class CardViewModel {
    //We'll define the properties that are view will display / render out
    let imageUrls: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    init(imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.imageUrls = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    fileprivate var imageIndex = 0 {
        didSet {
            let imageUrl = imageUrls[imageIndex]
            
            imageIndexObserve?(imageIndex, imageUrl)
        }
    }
    
    // Reactive Programming
    var imageIndexObserve: ( (Int, String?) -> ())?
    
    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageUrls.count - 1)
    }
    func goToPreviousPhoto() {
        imageIndex = max(0, imageIndex - 1 )
    }
}
