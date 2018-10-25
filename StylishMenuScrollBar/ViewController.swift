//
//  ViewController.swift
//  StylishMenuScrollBar
//
//  Created by park kyung suk on 2018/10/25.
//  Copyright © 2018年 park kyung suk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var menuTabScrollView: MenuTabScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        menuTabScrollView.delegate = self
        menuTabScrollView.dataSource = self
        
    }
}

extension ViewController: MenuTabScrollViewDelegate {
    func tabScrollView(_ tabScrollView: MenuTabScrollView, didChangePageTo index: Int) {
        print("didChanged: \(index)")
    }
    
    func tabScrollView(_ tabScrollView: MenuTabScrollView, didScrollPageTo index: Int) {
        print("didScrollPageTo: \(index)")
    }
    
    
}

extension ViewController: MenuTabScrollViewDataSource {
    func numberOfPagesInTabScrollView(_ tabScrollView: MenuTabScrollView) -> Int {
        return 10
    }
    
    func tabScrollView(_ tabScrollView: MenuTabScrollView, tabViewForPageAtIndex index: Int) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.backgroundColor = .blue
        return view
    }
    
    func tabScrollView(_ tabScrollView: MenuTabScrollView, contentViewForPageAtIndex index: Int) -> UIView {
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        view.backgroundColor = .red
        return view
    }
    
    
}
