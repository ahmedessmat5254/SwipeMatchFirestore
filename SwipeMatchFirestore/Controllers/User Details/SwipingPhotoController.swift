//
//  SwipingPhotoController.swift
//  SwipeMatchFirestore
//
//  Created by Ahmed Essmat on 29/04/2021.
//

import UIKit

class SwipingPhotoController: UIPageViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {

    var cardViewModel: CardViewModel! {
        didSet {
            print(cardViewModel.attributedString)
            
            controllers = cardViewModel.imageUrls.map { (imageUrl) -> UIViewController in
                let swipePhoto = photoController(imageUrl: imageUrl)
                return swipePhoto
            }
            setViewControllers([controllers.first!], direction: .forward, animated: false)
            setupBarView()
        }
        
    }
    
    var controllers = [UIViewController]()
   
    fileprivate let barStackView = UIStackView(arrangedSubviews: [])
    fileprivate let deselectedBarColor = UIColor(white: 0, alpha: 0.1)
    
    fileprivate func setupBarView () {
        cardViewModel.imageUrls.forEach { (_) in
            let barView = UIView()
            barView.backgroundColor = deselectedBarColor
            barView.layer.cornerRadius = 2
            barStackView.addArrangedSubview(barView)
        }
        barStackView.arrangedSubviews.first?.backgroundColor = .white
        barStackView.spacing = 8
        barStackView.distribution = .fillEqually
        
        view.addSubview(barStackView)
         let paddingTop = UIApplication.shared.statusBarFrame.height + 8
        
        barStackView.anchor(top: view.topAnchor, leading: view.leadingAnchor , bottom: nil, trailing: view.trailingAnchor, padding: .init(top: paddingTop , left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        print("Page transition completed")
        
        let currentPhotoController  = viewControllers?.first
        if let index = controllers.firstIndex(where: {$0 == currentPhotoController}) {
            barStackView.arrangedSubviews.forEach {$0.backgroundColor = deselectedBarColor}
            barStackView.arrangedSubviews[index].backgroundColor = .white
        }
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        view.backgroundColor = .white
     
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        let index = controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == 0 {return nil}
        
        return controllers[index - 1 ]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        let index = controllers.firstIndex(where: {$0 == viewController}) ?? 0
        if index == controllers.count - 1  {return nil}
        
        return controllers[index + 1]
    }
    
}

class photoController: UIViewController {
    
    let imageView = UIImageView(image: #imageLiteral(resourceName: "image-test1-1"))
    
    
    init(imageUrl: String) {
       
        if let url = URL(string: imageUrl) {
            imageView.sd_setImage(with: url, completed: nil)
        }
        super.init(nibName: nil, bundle: nil)
    }
    

    override func viewWillLayoutSubviews() {
        view.addSubview(imageView)
        imageView.fillSuperview()
        imageView.contentMode = .scaleAspectFill
        imageView.fillSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
