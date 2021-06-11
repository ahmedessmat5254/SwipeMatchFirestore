//
//  LoginViewModel.swift
//  SwipeMatchFirestore
//
//  Created by Ahmed Essmat on 18/04/2021.
//

import UIKit
import Firebase

class LoginViewModel {
    
    
    var isLogin = Bindable<Bool>()
    var isFormValid = Bindable<Bool>()
    
    var email: String? {didSet {checkFromValidity()}}
    var password: String? {didSet {checkFromValidity()}}
    
    fileprivate func checkFromValidity() {
        let isValid = email?.isEmpty == false && password?.isEmpty == false
        isFormValid.value = isValid
    }
    
    func performLogin(completion: @escaping (Error?) -> ()) {
        guard let email = email, let password = password else { return }
        isLogin.value = true
        Auth.auth().signIn(withEmail: email, password: password) { (res, err) in
            completion(err)
        }
        
    }
  
}
