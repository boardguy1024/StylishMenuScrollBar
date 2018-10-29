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
    let frontAndLastAddPageSize = 3
    
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
        scrollViewMain.contentSize = CGSize(width:CGFloat(pageSize + (frontAndLastAddPageSize * 2)) * width, height:0)
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
        //前後3個ずつ追加するため frontAndLastAddPageSize * 2
        scrollViewHeader.contentSize = CGSize(width:CGFloat(pageSize + (frontAndLastAddPageSize * 2)) * width, height:0)
        scrollViewHeader.isScrollEnabled = false
        scrollViewHeader.backgroundColor = .gray
        self.view.addSubview(scrollViewHeader)
        
        
        
        //Loopさせるために前後に黒いラベルを３個ずつをつける-----------------------------------------------
        //前
        //一番前から1,2,3ラベルをAdd
        for i in 0..<frontAndLastAddPageSize {
            let myLabel:UILabel = UILabel(frame: CGRect(x:(width*CGFloat(i)) + width/2 - 40, y:height/2 - 40, width:80, height:80))
            myLabel.backgroundColor = UIColor.black
            myLabel.textColor = UIColor.white
            myLabel.textAlignment = NSTextAlignment.center
            myLabel.layer.masksToBounds = true
            myLabel.text = "Page\((i + (pageSize - frontAndLastAddPageSize)))"
            myLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            myLabel.layer.cornerRadius = 40.0
            scrollViewMain.addSubview(myLabel)
            
        }
        
        //後
        //[0,1,2] [0,1,2,3,4,5,6,7,8,9] + 一番後ろに [0,1,2]ラベルをAdd
        for i in 0..<frontAndLastAddPageSize {
            let myLabel:UILabel = UILabel(frame: CGRect(x:(width*CGFloat(pageSize + frontAndLastAddPageSize + i)) + width/2 - 40, y:height/2 - 40, width:80, height:80))
            myLabel.backgroundColor = UIColor.black
            myLabel.textColor = UIColor.white
            myLabel.textAlignment = NSTextAlignment.center
            myLabel.layer.masksToBounds = true
            myLabel.text = "Page\((i))"
            myLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            myLabel.layer.cornerRadius = 40.0
            scrollViewMain.addSubview(myLabel)
            
        }
        //----------------------------------------------------------------------------------------------
        
        
        //Loopさせるために前後にラベルを３個ずつをつける-----------------------------------------------
        for i in 0..<frontAndLastAddPageSize {
            
            //前に３個ラベルAddする　
            //ページごとに異なるラベルを表示.
            let myLabel:UILabel = UILabel(frame: CGRect(x: CGFloat(i) * (width / 5), y:50, width:width/5, height:50))
            myLabel.backgroundColor = UIColor.red
            myLabel.textColor = UIColor.white
            myLabel.textAlignment = NSTextAlignment.center
            myLabel.layer.masksToBounds = true
            myLabel.text = "Page\((pageSize - frontAndLastAddPageSize) + i)"
            myLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            myLabel.layer.cornerRadius = 25
            myLabel.isUserInteractionEnabled = true
            scrollViewHeader.addSubview(myLabel)
            
            //後ろに３個ラベルAddする
            //ページごとに異なるラベルを表示.
            let lastLabel:UILabel = UILabel(frame: CGRect(x: (width / 5) * CGFloat(pageSize + frontAndLastAddPageSize + i), y:50, width:width/5, height:50))
            lastLabel.backgroundColor = UIColor.red
            lastLabel.textColor = UIColor.white
            lastLabel.textAlignment = NSTextAlignment.center
            lastLabel.layer.masksToBounds = true
            lastLabel.text = "Page\(i)"
            lastLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            lastLabel.layer.cornerRadius = 25
            lastLabel.isUserInteractionEnabled = true
            scrollViewHeader.addSubview(lastLabel)
        }
        
        
        //真ん中の黒いボタン
        // ScrollView1に貼付けるLabelの生成.
        for i in 0 ..< pageSize {
            
            //ページごとに異なるラベルを表示.
            //前に3個作成した後にAddするため　 (width*frontAndLastAddPageSize - 1)マージンを入れる
            let myLabel:UILabel = UILabel(frame: CGRect(x: (width*CGFloat(frontAndLastAddPageSize)) + CGFloat(i)*width + width/2 - 40, y:height/2 - 40, width:80, height:80))
            myLabel.backgroundColor = UIColor.black
            myLabel.textColor = UIColor.white
            myLabel.textAlignment = NSTextAlignment.center
            myLabel.layer.masksToBounds = true
            myLabel.text = "Page\(i)"
            myLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
            myLabel.layer.cornerRadius = 40.0
            scrollViewMain.addSubview(myLabel)
        }
        
        //赤いラベル
        // ScrollView2に貼付ける Labelの生成.
        for i in 0 ..< pageSize {
            
            //ページごとに異なるラベルを表示.
            let myLabel:UILabel = UILabel(frame: CGRect(x:CGFloat(i + frontAndLastAddPageSize)*width/5, y:50, width:width/5, height:50))
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
        
        //初期位置を２ページ目にする
        scrollViewMain.setContentOffset(CGPoint(x: width * CGFloat(frontAndLastAddPageSize), y: 0), animated: true)
        
    }
    
    
    @objc func buttonTapped(button: UIButton) {
        print("tapped")
        print("button tag: \(button.tag)")
    }
    
    @objc func tapped(gestureRecognizer: UITapGestureRecognizer) {
        print("tapped")
    }
    
    /*
     ScrollViewが移動した際に呼ばれる.
     */
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == scrollViewMain {
            //0番目が真ん中に来るように調整
//            let leftInset = (view.frame.width / 5) * 2
            scrollViewHeader.contentOffset.x =  (scrollViewMain.contentOffset.x/5) //- leftInset
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let currentPage = Int(scrollView.contentOffset.x / view.frame.width)
        self.currentPage = currentPage
        
        print("currentPage: \(self.currentPage)")
        
        let width = self.view.frame.width
        
        if currentPage == 0 {
            scrollViewMain.contentOffset.x = width * CGFloat(pageSize)
        }
        else if currentPage == pageSize {
            scrollViewMain.contentOffset.x = 0
            
        }

    }
    
    
    
}


