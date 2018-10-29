//
//  LoopViewController.swift
//  StylishMenuScrollBar
//
//  Created by park kyung suk on 2018/10/28.
//  Copyright © 2018年 park kyung suk. All rights reserved.
//

import UIKit

class LoopViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    var widthOfScroll: CGFloat = 0
    let heightOfScroll: CGFloat = 240
    var widthOfImage: CGFloat = 0
    let heightOfImage: CGFloat = 240
    let slideImageStrings: [UIColor]  = [.red, .yellow, .blue]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        widthOfScroll = view.frame.width
        widthOfImage = view.frame.width
        
        scrollView.bounces = true
        scrollView.isPagingEnabled = true
        scrollView.delegate = self
        scrollView.isUserInteractionEnabled = true
        
    
        //最後イメージ
        let lastImageView = UIImageView()
        lastImageView.backgroundColor = slideImageStrings.last!
        lastImageView.frame = CGRect(x: 0, y: 0, width: widthOfImage, height: heightOfImage)
        scrollView.addSubview(lastImageView)
        
        //ループ
        slideImageStrings.enumerated().forEach { index, name in
            
            let imgView = UIImageView()
            imgView.backgroundColor = slideImageStrings[index]
            imgView.frame = CGRect(x: widthOfImage * CGFloat(index) + widthOfImage, y: 0, width: widthOfImage, height: heightOfImage)
            scrollView.addSubview(imgView)
        }
        
        let firstImageView = UIImageView()
        firstImageView.backgroundColor = slideImageStrings.first!
        firstImageView.frame = CGRect(x: widthOfImage * CGFloat(slideImageStrings.count + 1), y: 0, width: widthOfImage, height: heightOfImage)
        scrollView.addSubview(firstImageView)
        
        scrollView.contentSize = CGSize(width: widthOfScroll * CGFloat(slideImageStrings.count + 2), height: heightOfScroll)
        
        //初期位置を２ページ目にする
        scrollView.setContentOffset(CGPoint(x: widthOfScroll, y: 0), animated: true)
        
        
    }
}

extension LoopViewController: UIScrollViewDelegate {
    
    //スクロール終わった時
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage: Int = Int(scrollView.contentOffset.x / widthOfScroll)
        
        print("currentPage: \(currentPage)")
        if currentPage == 0 {
            scrollView.scrollRectToVisible(CGRect(x: widthOfScroll * CGFloat(slideImageStrings.count), y: 0, width: widthOfScroll, height: heightOfScroll), animated: false)
            
            scrollView.contentOffset.x = widthOfScroll * CGFloat(slideImageStrings.count)
        }
        else if currentPage == slideImageStrings.count + 1 {
            scrollView.scrollRectToVisible(CGRect(x: widthOfScroll, y: 0, width: widthOfImage, height: heightOfImage), animated: false)
        }
    }
}
