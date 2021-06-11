//
//  SettingsController.swift
//  SwipeMatchFirestore
//
//  Created by Ahmed Essmat on 06/04/2021.
//

import UIKit
import Firebase
import JGProgressHUD
import SDWebImage

protocol SettingsControllerDelegate {
    func didSaveSettings()
}

class CustomImagePickerController: UIImagePickerController {
    
    var imageButton: UIButton?
    
}

class SettingsController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var delegate: SettingsControllerDelegate?
    // instance properties
    lazy var image1Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image2Button = createButton(selector: #selector(handleSelectPhoto))
    lazy var image3Button = createButton(selector: #selector(handleSelectPhoto))
    
    @objc func handleSelectPhoto(button: UIButton) {
        print("Select photo with button:", button)
        let imagePicker = CustomImagePickerController()
        imagePicker.delegate = self
        imagePicker.imageButton = button
        present(imagePicker, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[.originalImage] as? UIImage
        // how do i set the image on my buttons when I select a photo?
        let imageButton = (picker as? CustomImagePickerController)?.imageButton
        imageButton?.setImage(selectedImage?.withRenderingMode(.alwaysOriginal), for: .normal)
        dismiss(animated: true)
        
        let fileName = UUID().uuidString
        let ref = Storage.storage().reference(withPath: "/images/\(fileName)")
        guard let uploadImage = selectedImage?.jpegData(compressionQuality: 0.75) else { return }
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Uploading Image"
        hud.show(in: view)
        ref.putData(uploadImage, metadata: nil) { (_, err) in
            hud.dismiss()
            if let err = err {
                print("Failed to upload image to storage", err)
                return
            }
            print("Finnish to upload image")
            ref.downloadURL { (url, err) in
                hud.dismiss()
                if let err = err {
                    print("Failed to retrieve download url", err)
                    return
                    
                }
                print("finished  to get download image url ",url?.absoluteURL ?? "")
                
                if imageButton == self.image1Button {
                    self.user?.imageUrl1 = url?.absoluteString
                }else if imageButton == self.image2Button {
                    self.user?.imageUrl2 = url?.absoluteString
                }else {
                    self.user?.imageUrl3 = url?.absoluteString
                }
                
            }

        }
    }
    
    func createButton(selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle("Select Photo", for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 8
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationItems()
        tableView.backgroundColor = UIColor(white: 0.95, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.keyboardDismissMode = .interactive
        tableView.delaysContentTouches = false
        fetchCurrentUser()
    }
    
    var user: User?
    
    fileprivate func fetchCurrentUser() {
        // fetch some Firestore Data
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot, err) in
            if let err = err {
                print(err)
                return
            }
            
            // fetched our user here
            guard let dictionary = snapshot?.data() else { return }
            self.user = User(dictionary: dictionary)
            self.loadUserPhotos()
            
            self.tableView.reloadData()
        }
    }
    
    fileprivate func loadUserPhotos() {
        if  let imageUrl = user?.imageUrl1, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image1Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if  let imageUrl = user?.imageUrl2, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image2Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
        if  let imageUrl = user?.imageUrl3, let url = URL(string: imageUrl) {
            SDWebImageManager.shared().loadImage(with: url, options: .continueInBackground, progress: nil) { (image, _, _, _, _, _) in
                self.image3Button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
            }
        }
    }
    
    lazy var header: UIView = {
        let header = UIView()
        header.addSubview(image1Button)
        let padding: CGFloat = 16
        image1Button.anchor(top: header.topAnchor, leading: header.leadingAnchor, bottom: header.bottomAnchor, trailing: nil, padding: .init(top: padding, left: padding, bottom: padding, right: 0))
        image1Button.widthAnchor.constraint(equalTo: header.widthAnchor, multiplier: 0.45).isActive = true
        
        let stackView = UIStackView(arrangedSubviews: [image2Button, image3Button])
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = padding
        
        header.addSubview(stackView)
        stackView.anchor(top: header.topAnchor, leading: image1Button.trailingAnchor, bottom: header.bottomAnchor, trailing: header.trailingAnchor, padding: .init(top: padding, left: padding, bottom: padding, right: padding))
        return header
    }()
    
    class HeaderLabel: UILabel {
        override func drawText(in rect: CGRect) {
            super.drawText(in: rect.insetBy(dx: 16, dy: 0))
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            return header
        }
        let headerLabel = HeaderLabel()
        switch section {
        case 1:
            headerLabel.text = "Name"
        case 2:
            headerLabel.text = "Profession"
        case 3:
            headerLabel.text = "Age"
        case 4:
            headerLabel.text = "Bio"

        default:
            headerLabel.text = "Seeking Age Range"
        }
        headerLabel.font = UIFont.boldSystemFont(ofSize: 16)
        return headerLabel
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 300
        }
        return 40
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 6
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        for view in tableView.subviews {
                   if view is UIScrollView {
                       (view as? UIScrollView)!.delaysContentTouches = true
                       break
                   }
               }
        return section == 0 ? 0 : 1

    }
    

    
//    func evaluateMinMx() {
//        guard let ageRangeCell = tableView.cellForRow(at: [5,0]) as? AgeRangeCell else { return }
//        let minValue = Int(ageRangeCell.minSlider.value)
//        var maxValue = Int(ageRangeCell.maxSlider.value)
//        maxValue = max(minValue, maxValue)
//        ageRangeCell.minLabel.text = "Min \(minValue)"
//        ageRangeCell.maxLabel.text = "Max \(maxValue)"
//
//        user?.minSeekingAge = minValue
//        user?.maxSeekingAge = maxValue
//
//    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
            return nil
        }
    
    static let defaultMinSeekingAge = 18
    static let defaultMaxSeekingAge = 50
     
     override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         // Age Range Cell
                if indexPath.section == 5 {
                    let ageRangeCell = AgeRangeCell(style: .default, reuseIdentifier: nil)
                    ageRangeCell.minSlider.addTarget(self, action: #selector(handelMinAgeChange), for: .valueChanged)
                    ageRangeCell.maxSlider.addTarget(self, action: #selector(handelMaxAgeChange), for: .valueChanged)
                    
                    let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge
                    let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge
                    
                    ageRangeCell.minLabel.text = "Min \(minAge)"
                    ageRangeCell.minSlider.value = Float(minAge)
                    ageRangeCell.maxLabel.text = "Max \(maxAge)"
                    ageRangeCell.maxSlider.value = Float(maxAge)
                    return ageRangeCell
                }
                
                let cell = SettingsCells(style: .default, reuseIdentifier: nil)
                
                switch indexPath.section {
                case 1:
                    cell.textField.placeholder = "Enter Name"
                    cell.textField.text = user?.name
                    cell.textField.addTarget(self, action: #selector(handleNameChange), for: .editingChanged)
                case 2:
                    cell.textField.placeholder = "Enter Profession"
                    cell.textField.text = user?.profession
                    cell.textField.addTarget(self, action: #selector(handleProfessionChange), for: .editingChanged)
                case 3:
                    cell.textField.placeholder = "Enter Age"
                    cell.textField.addTarget(self, action: #selector(handleAgeChange), for: .editingChanged)
                    if let age = user?.age {
                        cell.textField.text = String(age)
                    }
                default:
                    cell.textField.placeholder = "Enter Bio"
                }
                return cell
    }
    
    @objc fileprivate func handelMinAgeChange(slider: UISlider) {
        let indexPath = IndexPath(row: 0, section: 5)
               let ageRangeCell = tableView.cellForRow(at: indexPath) as! AgeRangeCell
               if slider.value >= ageRangeCell.maxSlider.value {
                   ageRangeCell.maxSlider.value = slider.value
               }
               ageRangeCell.minLabel.text = "Min \(Int(slider.value))"
               ageRangeCell.maxLabel.text = "Max \(Int(ageRangeCell.maxSlider.value))"
               
               self.user?.minSeekingAge = Int(slider.value)    }
    @objc fileprivate func handelMaxAgeChange(slider: UISlider) {
        let indexPath = IndexPath(row: 0, section: 5)
                let ageRangeCell = tableView.cellForRow(at: indexPath) as! AgeRangeCell
                if slider.value <= ageRangeCell.minSlider.value {
                    ageRangeCell.minSlider.value = slider.value
                }
                ageRangeCell.maxLabel.text = "Max \(Int(slider.value))"
                ageRangeCell.minLabel.text = "Min \(Int(ageRangeCell.minSlider.value))"
                
                self.user?.maxSeekingAge = Int(slider.value)
        
    }
    fileprivate func setupNavigationItems() {
        navigationItem.title = "Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave)),
            UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        ]
    }
    
    @objc fileprivate func handleLogout() {
        try? Auth.auth().signOut()
        dismiss(animated: true, completion: nil)
    }
    @objc fileprivate func handleNameChange(textField: UITextField) {
        print("Name Change \(textField.text ?? "")")
        self.user?.name = textField.text
    }
    
    @objc fileprivate func handleProfessionChange(textField: UITextField) {
        print("Profession Change \(textField.text ?? "")")
        self.user?.profession = textField.text
    }
    
    @objc fileprivate func handleAgeChange(textField: UITextField) {
        print("Age Change \(textField.text ?? " ")")
        self.user?.age = Int(textField.text ?? "")
    }
    
    @objc fileprivate func handleSave() {
        print("Saving our settings data into firebase")
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let docData: [String: Any] = [
            "uid": uid,
            "fullName": user?.name ?? "",
            "imageUrl1": user?.imageUrl1 ?? "",
            "imageUrl2": user?.imageUrl2 ?? "",
            "imageUrl3": user?.imageUrl3 ?? "",
            "age": user?.age ?? -1,
            "profession": user?.profession ?? "",
            "minSeekingAge": user?.minSeekingAge ?? -1 ,
            "maxSeekingAge": user?.maxSeekingAge ?? -1 ,
            
        ]
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Saving settings"
        hud.show(in: view)
        
        Firestore.firestore().collection("users").document(uid).setData(docData) { (err) in
            hud.dismiss()
            if let err = err {
                print("Failed to save users settings", err)
                return
            }
            print("Finished save user setting")
            self.dismiss(animated: true) {
                print("Dismiss complete")
                self.delegate?.didSaveSettings()
            }
            
        }
    }
    @objc fileprivate func handleCancel() {
        dismiss(animated: true)
    }
}
