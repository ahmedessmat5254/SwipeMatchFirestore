//
//  RegistrationViewModel.swift
//  SwipeMatchFirestore
//
//  Created by Ahmed Essmat on 25/03/2021.
//

import UIKit
import Firebase

class RegistrationViewModel {
    
    var bindableImage = Bindable<UIImage>()
    var bindableIsRegistering = Bindable<Bool>()
    var bindableIsFormValid = Bindable<Bool>()

    
//    var image: UIImage? {
//        didSet {
//            imageObserver?(image)
//        }
//    }
//
//    var imageObserver: ((UIImage?) -> ())?
    
    var fullName: String?  {
        didSet {
            checkFormValidity()
        }
    }
    
    var email: String? {
        didSet {
            checkFormValidity()
        }
    }
    
    var password: String? {
        didSet {
            checkFormValidity()
        }
    }
    
    
    fileprivate func checkFormValidity () {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty == false && password?.isEmpty == false
        bindableIsFormValid.value = isFormValid
//        ifFormValidObserve?(isFormValid)
    }
    
    func performRegistration(completion: @escaping (Error?) -> ()){
        guard let email = email, let password = password else {return}
        bindableIsRegistering.value = true
        Auth.auth().createUser(withEmail: email, password: password) { (res, err) in
            if let err = err{
               completion(err)
                return
            }

            self.saveImageToFirebase(completion: completion)
            print("Successfully registered user:", res?.user.uid ?? "")

        }
     
    }
    fileprivate func saveImageToFirebase(completion: @escaping (Error?) -> ()) {
        let filename = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(filename)")
        let imageData = self.bindableImage.value?.jpegData(compressionQuality: 0.75) ?? Data()
        ref.putData(imageData, metadata: nil, completion: {(_, err) in
            if let err = err {
                completion(err)
                return
            }
            print("Finishing uploading image to storage")
            ref.downloadURL(completion: {(url, err) in
                if let err = err {
                    completion(err)
                    return
                }
                self.bindableIsRegistering.value = false
                print("Download URL of our image is:", url?.absoluteURL ?? " ")
                let imageUrl = url?.absoluteString ?? ""
                self.saveInfoToFirebase(imageUrl: imageUrl,completion: completion )
            })
        })
    }
    
    fileprivate func saveInfoToFirebase(imageUrl:String, completion: @escaping (Error?) -> ()) {
        let uid = Auth.auth().currentUser?.uid ?? ""
        let docData = ["fullName": fullName ?? "", "uid": uid, "imageUrl1": imageUrl]
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            if let err = err {
                completion(err)
                return
            }
            completion(nil)
        }
    }
    fileprivate func checkFromValidity() {
        let isFormValid = fullName?.isEmpty == false && email?.isEmpty  == false
        bindableIsFormValid.value = isFormValid
    }
    
    
    
}
    

    
    
 
