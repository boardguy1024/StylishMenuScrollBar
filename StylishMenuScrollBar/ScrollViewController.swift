//
//  ScrollViewController.swift
//  StylishMenuScrollBar
//
//  Created by park kyung suk on 2018/10/26.
//  Copyright © 2018年 park kyung suk. All rights reserved.
//

import UIKit

class ScrollViewController: UIViewController {

    @IBOutlet weak var pageScrollView: UIScrollView!
    @IBOutlet weak var buttonsScrollView: UIScrollView!
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pageScrollView.delegate = self
        pageScrollView.tag = 1
        buttonsScrollView.tag = 2
        buttonsScrollView.delegate = self
        pageScrollView.isPagingEnabled = true
//        pageScrollView.contentSize = CGSize(width: view.frame.width * 5, height: 50)
       // pageScrollView.contentSize = CGSize(width: (view.frame.width / 3) * 5, height: 50 )
      //  pageScrollView.bounds = CGRect(x: 0, y: 0, width: view.frame.width / 3, height: 50)
//        scroll.bounds = CGRectMake(0.0, 0.0, 150.0 + margin, 200.0);
//
//        scroll.contentSize = CGSizeMake(150.0*3 + margin*3, 200.0);
//
        
        
        //buttonsScrollView.isUserInteractionEnabled = false
        loadButtons()
        buttonsScrollView.contentSize = CGSize(width: (view.frame.width / 3) * 5, height: 50)
        buttonsScrollView.bounds = CGRect(x: 0, y: 0, width: 100, height: 50)
        
        pageScrollView.showsHorizontalScrollIndicator = false
    }
    
    func loadButtons() {
        
        for index in 0..<5 {
            guard let buttonView = Bundle.main.loadNibNamed("ButtonView", owner: self, options: nil)?.first as? ButtonView else { return }
            buttonView.backgroundColor = .red
            buttonsScrollView.addSubview(buttonView)
            buttonView.frame.size.width = self.view.bounds.width / 3
            buttonView.frame.origin.x = CGFloat(index) * self.view.bounds.width / 3
            
            
        }
        
    }
    


}

extension ScrollViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
//        if scrollView.tag == 1 {
        
        print(scrollView.contentOffset.x)
        
        if scrollView.contentOffset.x > 100 {
            buttonsScrollView.contentOffset.x = (scrollView.contentOffset.x / 3)
        }
         //   buttonsScrollView.contentOffset.x = (scrollView.contentOffset.x / 3)
//
//            if buttonsScrollView.contentOffset.x < (buttonsScrollView.contentSize.width - (view.frame.width / 3)) {
//                print(buttonsScrollView.contentSize)
//
//            }
//
//
//        }
    }
}
