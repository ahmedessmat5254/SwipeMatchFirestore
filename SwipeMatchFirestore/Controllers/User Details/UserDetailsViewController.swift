//
//  UserDetailsViewController.swift
//  SwipeMatchFirestore
//
//  Created by Ahmed Essmat on 22/04/2021.
//

import UIKit
import SDWebImage

class UserDetailsViewController: UIViewController, UIScrollViewDelegate {
    var cardViewModel: CardViewModel!{
        didSet {
            infoLabel.attributedText = cardViewModel.attributedString
            
            swipingPhotoController.cardViewModel = cardViewModel
            
            
          //guard let firstImageUrl = cardViewModel.imageUrls.first, let url = URL(string: firstImageUrl) else {return}
          //imageView.sd_setImage(with: url)
        }
    }
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never
        sv.delegate = self
        return sv
    }()
    
//    let imageView: UIImageView = {
//        let imageView = UIImageView(image: #imageLiteral(resourceName: "IMG_20200407_011451"))
//        imageView.clipsToBounds = true
//        imageView.contentMode = .scaleAspectFill
//        return imageView
//    }()
    let swipingPhotoController = SwipingPhotoController(transitionStyle: .scroll, navigationOrientation: .horizontal)

    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "User name 30\nDoctor\nSome bio text down below"
        label.numberOfLines = 0
        return label
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(#imageLiteral(resourceName: "dismiss_down_arrow").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleTapDismiss), for: .touchUpInside)
        return button
    }()
    
    lazy var dislikeButton = self.createButton(image: #imageLiteral(resourceName: "dismiss_circle"), selector: #selector(handleDislike))
    lazy var superLikeButton = self.createButton(image: #imageLiteral(resourceName: "super_like_circle"), selector: #selector(handleSuperLike))
    lazy var likeButton =  self.createButton(image: #imageLiteral(resourceName: "like_circle"), selector: #selector(handleLike))
   
    @objc func handleDislike() {
        dismiss(animated: true)
    }
    @objc func handleSuperLike() {
        dismiss(animated: true)
    }
    @objc func handleLike() {
        dismiss(animated: true)
    }

    fileprivate func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleToFill
        return  button
    }
    
   
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        setupLayout()
        setupVisualEffectView()
        setupBottomControls()


    
    }
   
    
    
    fileprivate func setupLayout() {
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        let imageView = swipingPhotoController.view!
        
        scrollView.addSubview(imageView)
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: imageView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 00, right: 16))
        
        scrollView.addSubview(dismissButton)
        dismissButton.anchor(top: imageView.bottomAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: -25, left: 0, bottom: 0, right: 24), size: .init(width: 50, height: 50))
    }
    
    
 
    

    fileprivate func  setupVisualEffectView() {
        let bluerEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: bluerEffect)
        view.addSubview(visualEffectView)
        visualEffectView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    fileprivate func setupBottomControls() {
        let stackView = UIStackView(arrangedSubviews: [dislikeButton, superLikeButton, likeButton])
        stackView.distribution = .fillEqually
        stackView.spacing = -32
        view.addSubview(stackView)
        
        stackView.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor , trailing: nil,  padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 80))
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
   
    fileprivate let extraSwipingHight: CGFloat = 140
    
    override func viewWillLayoutSubviews() {
        
        super.viewWillLayoutSubviews()
        let swipingView = swipingPhotoController.view!
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingHight)
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
        print(changeY)
        var width = view.frame.width + changeY * 2
        width = max(view.frame.width, width)
        let imageView = swipingPhotoController.view!
        imageView.frame = CGRect(x: min(0, -changeY), y: min(0, -changeY), width: width, height: width + extraSwipingHight)
    }
    
    @objc func handleTapDismiss() {
        dismiss(animated: true)
    }
    

}
