//
//  MyViewController.swift
//  StylishMenuScrollBar
//
//  Created by park kyung suk on 2018/10/27.
//  Copyright © 2018年 park kyung suk. All rights reserved.
//

import UIKit

class MyViewController: UIViewController, UIScrollViewDelegate {


    // UIScrillView.
    var scrollViewHeader: UIScrollView!
    var scrollViewMain: UIScrollView!
    // ページ番号.
    let pageSize = 10
    
    var currentPage: Int = 0
    
    //ループさせるためのへ要素
    private var startPoint: CGPoint!
    //表示するページビューのArray
    private var pageViewArray: [UIView] = []
    
    
    override func viewDidLoad() {
        
        // 画面サイズの取得.
        let width = self.view.frame.maxX, height = self.view.frame.maxY
        
       
        
        // ScrollViewMainの設定.
        scrollViewMain = UIScrollView(frame: self.view.frame)
        scrollViewMain.showsHorizontalScrollIndicator = false
        scrollViewMain.showsVerticalScrollIndicator = false
        scrollViewMain.isPagingEnabled = true
        scrollViewMain.delegate = self
        scrollViewMain.contentSize = CGSize(width:CGFloat(pageSize) * width, height:0)
        self.view.addSubview(scrollViewMain)
        scrollViewMain.isUserInteractionEnabled = true
        scrollViewMain.isScrollEnabled = true
      
        //ボタンがあるScrollView
        // ScrollViewHeaderの設定.
        scrollViewHeader = UIScrollView(frame: CGRect(x: 0, y: 0, width: width, height: 1))
        scrollViewHeader.clipsToBounds = false
        scrollViewHeader.showsHorizontalScrollIndicator = false
        scrollViewHeader.showsVerticalScrollIndicator = false
        scrollViewHeader.delegate = self
        scrollViewHeader.contentSize = CGSize(width:CGFloat(pageSize) * width, height:0)
        scrollViewHeader.isScrollEnabled = false
        scrollViewHeader.backgroundColor = .gray
        self.view.addSubview(scrollViewHeader)
        
        
        
        
        // ScrollView1に貼付けるLabelの生成.
        for i in 0 ..< pageSize {
            
            //真ん中の黒いボタン
            //ページごとに異なるラベルを表示.
            let myLabel:UILabel = UILabel(frame: CGRect(x:CGFloat(i)*width+width/2-40, y:height/2 - 40, width:80, height:80))
            myLabel.backgroundColor = UIColor.black
            myLabel.textColor = UIColor.white
            myLabel.textAlignment = NSTextAlignment.center
            myLabel.layer.masksToBounds = true
            myLabel.text = "Page\(i)"
            myLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            myLabel.layer.cornerRadius = 40.0
            scrollViewMain.addSubview(myLabel)
        }
        
        // ScrollView2に貼付ける Labelの生成.
        for i in 0 ..< pageSize {
            
            //ページごとに異なるラベルを表示.
            let myLabel:UILabel = UILabel(frame: CGRect(x:CGFloat(i)*width/5, y:50, width:width/5, height:50))
            myLabel.backgroundColor = UIColor.red
            myLabel.textColor = UIColor.white
            myLabel.textAlignment = NSTextAlignment.center
            myLabel.layer.masksToBounds = true
            myLabel.text = "Page\(i)"
            myLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            myLabel.layer.cornerRadius = 25
            myLabel.isUserInteractionEnabled = true
            scrollViewHeader.addSubview(myLabel)
            let tabGesture = UITapGestureRecognizer(target: self, action: #selector(tapped))
            myLabel.addGestureRecognizer(tabGesture)
            
   
        }
        
    }
    
    @objc func buttonTapped(button: UIButton) {
        print("tapped")
        print("button tag: \(button.tag)")
    }
    
    @objc func tapped(gestureRecognizer: UITapGestureRecognizer) {
        print("tapped")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //0番目が真ん中に来るように調整
        scrollViewHeader.contentOffset.x =  (scrollViewMain.contentOffset.x/5) - ((view.frame.width / 5) * 2)
    }
    
    /*
     ScrollViewが移動した際に呼ばれる.
     */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == scrollViewMain {
            //0番目が真ん中に来るように調整
            let leftInset = (view.frame.width / 5) * 2
            scrollViewHeader.contentOffset.x =  (scrollViewMain.contentOffset.x/5) - leftInset
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.currentPage = Int(scrollView.contentOffset.x / view.frame.width)
        
        print("currentPage: \(self.currentPage)")
    }
    
}
