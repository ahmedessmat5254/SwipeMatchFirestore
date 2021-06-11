//
//  LoginController.swift
//  SwipeMatchFirestore
//
//  Created by Ahmed Essmat on 18/04/2021.
//

import UIKit
import JGProgressHUD

protocol LogControllerDelegate {
    func didFinishLogIn()
}
class LoginController: UIViewController {

    var delegate: LogControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        setupBindables()
        setupGradientLayer()
        setupLayout()
        
    }

    let emailTextField: CustomTextField = {
       let textField = CustomTextField(padding:24)
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.placeholder = "Enter email"
        textField.backgroundColor = .white
        textField.keyboardType = .emailAddress
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return textField
    }()
    
    let passwordTextField: CustomTextField = {
        let textField = CustomTextField(padding: 24)
        textField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        textField.backgroundColor
            = .white
        textField.placeholder = "Enter password"
        textField.isSecureTextEntry = true
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        return textField
        
    }()
    
    @objc func handleTextChange (textField: UITextField) {
        
        if textField == emailTextField {
            loginViewModel.email = textField.text
        } else {
            loginViewModel.password = textField.text
        }
    }
    
    lazy var verticalStackView: UIStackView = {
        let sv = UIStackView(arrangedSubviews: [
            emailTextField,
            passwordTextField,
            loginButton
        ])
        sv.axis = .vertical
        sv.spacing = 8
        
        return sv
    }()
    
    fileprivate var loginViewModel = LoginViewModel()
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .heavy)
        button.isEnabled = false
        button.backgroundColor = .lightGray
        button.heightAnchor.constraint(equalToConstant: 44).isActive = true
        button.layer.cornerRadius = 22
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        
        return button
    }()
    
    @objc func handleLogin() {
        
        loginViewModel.performLogin { (err) in
            self.loginHUD.dismiss()
            if let err = err {
                print("Failed to login: ", err)
                return
            }
            
            print("Logged in successfully")
            self.dismiss(animated: true) {
                self.delegate?.didFinishLogIn()
            }
        }
    }
    
    fileprivate let backToRegistrationButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitle("Go back", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        return button
        
    }()
    
    fileprivate let loginHUD = JGProgressHUD(style: .dark)
    
    fileprivate func setupBindables() {
        loginViewModel.isFormValid.bind { [unowned self] (isFormValid) in
            guard let isFormValid = isFormValid else { return }
            self.loginButton.isEnabled = isFormValid
            self.loginButton.backgroundColor = isFormValid ? #colorLiteral(red: 0.8235294118, green: 0, blue: 0.3254901961, alpha: 1) : .lightGray
            self.loginButton.setTitleColor(isFormValid ? .white : .gray, for: .normal)
        }
        loginViewModel.isLogin.bind { [unowned self] (isRegistering) in
            if isRegistering == true {
                self.loginHUD.textLabel.text = "Register"
                self.loginHUD.show(in: self.view)
            } else {
                self.loginHUD.dismiss()
            }
        }
    }
    
    let gradientLayer = CAGradientLayer()
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        gradientLayer.frame = view.bounds
    }
    
    fileprivate func setupGradientLayer() {
        let topColor = #colorLiteral(red: 0.9921568627, green: 0.3568627451, blue: 0.3725490196, alpha: 1)
        let bottomColor = #colorLiteral(red: 0.8980392157, green: 0, blue: 0.4470588235, alpha: 1)
        // make sure to user cgColor
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0, 1]
        view.layer.addSublayer(gradientLayer)
        gradientLayer.frame = view.bounds
    }
    @objc fileprivate func handleBack() {
        
        navigationController?.popViewController(animated: true)
    }
    
    
    
    fileprivate func setupLayout() {
        navigationController?.isNavigationBarHidden = true
        view.addSubview(verticalStackView)
        verticalStackView.anchor(top: nil, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: 0, left: 50, bottom: 0, right: 50))
        verticalStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(backToRegistrationButton)
        backToRegistrationButton.anchor(top: nil, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        
    }
    
    
}
