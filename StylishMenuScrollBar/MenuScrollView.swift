//
//  MenuScrollView.swift
//  StylishMenuScrollBar
//
//  Created by park kyung suk on 2018/10/25.
//  Copyright © 2018年 park kyung suk. All rights reserved.
//

import UIKit

public protocol MenuTabScrollViewDelegate {
    
    // 特定のページに止まるためのトリガー
    func tabScrollView(_ tabScrollView: MenuTabScrollView, didChangePageTo index: Int)
    
    // triggered by scrolling through any pages
    // ページを通じてスクロールによるトリガー
    func tabScrollView(_ tabScrollView: MenuTabScrollView, didScrollPageTo index: Int)
}

public protocol MenuTabScrollViewDataSource {
    
    // get pages count
    //ページのカウント
    func numberOfPagesInTabScrollView(_ tabScrollView: MenuTabScrollView) -> Int
    
    // get the tab at index
    //indexのViewを返却
    func tabScrollView(_ tabScrollView: MenuTabScrollView, tabViewForPageAtIndex index: Int) -> UIView
    
}


open class MenuTabScrollView: UIView, UIScrollViewDelegate {
    // MARK: Public Variables
    @IBInspectable open var defaultPage: Int = 0
    @IBInspectable open var tabSectionHeight: CGFloat = -1
    
    //backGroundColor
    @IBInspectable open var tabSectionBackgroundColor: UIColor = UIColor.white
    
    // paging
    @IBInspectable open var contentSectionBackgroundColor: UIColor = UIColor.white
    
    //カレントではないタブに薄いグラデーションをかけるかどうか
//    @IBInspectable open var needsTabGradient: Bool = true
    
    @IBInspectable open var pagingEnabled: Bool = true {
        didSet {
            contentSectionScrollView.isPagingEnabled = pagingEnabled
        }
    }
    @IBInspectable open var cachedPageLimit: Int = 3
    
    open var delegate: MenuTabScrollViewDelegate?
    open var dataSource: MenuTabScrollViewDataSource?
    
    // MARK: Private Variables
    fileprivate var tabSectionScrollView: UIScrollView!
    fileprivate var contentSectionScrollView: UIScrollView!
    
    fileprivate var cachedPageTabs: [Int: UIView] = [:]
    fileprivate var cachedPageContents: CacheQueue<Int, UIView> = CacheQueue()
    fileprivate var realcachedPageLimit: Int {
        var limit = 3
        if (cachedPageLimit > 3) {
            limit = cachedPageLimit
        } else if (cachedPageLimit < 1) {
            limit = numberOfPages
        }
        return limit
    }
    
    fileprivate var isStarted = false
    fileprivate var pageIndex: Int!
    fileprivate var prevPageIndex: Int?
    
    fileprivate var isWaitingForPageChangedCallback = false
    fileprivate var pageChangedCallback: (() -> Void)?
    
    // MARK: DataSource
    fileprivate var numberOfPages = 0
    
    fileprivate func widthForTabAtIndex(_ index: Int) -> CGFloat {
        return cachedPageTabs[index]?.frame.width ?? 0
    }
    
    fileprivate func tabViewForPageAtIndex(_ index: Int) -> UIView? {
        return dataSource?.tabScrollView(self, tabViewForPageAtIndex: index)
    }
    
    
    // MARK: Init
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    private func initialize() {
        // init views
        tabSectionScrollView = UIScrollView()
        contentSectionScrollView = UIScrollView()
        
        self.addSubview(tabSectionScrollView)
        self.addSubview(contentSectionScrollView)

        tabSectionScrollView.isPagingEnabled = false
        tabSectionScrollView.showsHorizontalScrollIndicator = false
        tabSectionScrollView.showsVerticalScrollIndicator = false
        tabSectionScrollView.delegate = self
        
        contentSectionScrollView.isPagingEnabled = pagingEnabled
        contentSectionScrollView.showsHorizontalScrollIndicator = false
        contentSectionScrollView.showsVerticalScrollIndicator = false
        contentSectionScrollView.delegate = self
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        // set custom attrs
        tabSectionScrollView.backgroundColor = self.tabSectionBackgroundColor
        contentSectionScrollView.backgroundColor = self.contentSectionBackgroundColor
  
        // first time setup pages
        setupPages()
        
    }
    
    
    // MARK: - Tab Clicking Control
    @objc func tabViewDidClick(_ sensor: UITapGestureRecognizer) {
        activedScrollView = tabSectionScrollView
        moveToIndex(sensor.view!.tag, animated: true)
    }
    
    @objc func tabSectionScrollViewDidClick(_ sensor: UITapGestureRecognizer) {
        activedScrollView = tabSectionScrollView
        moveToIndex(pageIndex, animated: true)
    }
    
    // MARK: - Scrolling Control
    fileprivate var activedScrollView: UIScrollView?
    
    // scrolling animation begin by dragging
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        // stop current scrolling before start another scrolling
        stopScrolling()
        // set the activedScrollView
        activedScrollView = scrollView
    }
    
    // scrolling animation stop with decelerating
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        moveToIndex(currentPageIndex(), animated: true)
    }
    
    // scrolling animation stop without decelerating
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if (!decelerate) {
            moveToIndex(currentPageIndex(), animated: true)
        }
    }
    
    // scrolling animation stop programmatically
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        if (isWaitingForPageChangedCallback) {
            isWaitingForPageChangedCallback = false
            pageChangedCallback?()
        }
    }
    
    // scrolling
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        
        let currentIndex = currentPageIndex()
        
        if (scrollView == activedScrollView) {
            let speed = self.frame.width / widthForTabAtIndex(currentIndex)
            let halfWidth = self.frame.width / 2
            
            var tabsWidth: CGFloat = 0
            var contentsWidth: CGFloat = 0
            for i in 0 ..< currentIndex {
                tabsWidth += widthForTabAtIndex(i)
                contentsWidth += self.frame.width
            }
            
            if (scrollView == tabSectionScrollView) {
                contentSectionScrollView.contentOffset.x = ((tabSectionScrollView.contentOffset.x + halfWidth - tabsWidth) * speed) + contentsWidth - halfWidth
            }
            
            if (scrollView == contentSectionScrollView) {
                tabSectionScrollView.contentOffset.x = ((contentSectionScrollView.contentOffset.x + halfWidth - contentsWidth) / speed) + tabsWidth - halfWidth
            }
        }
        
        if (pageIndex != currentIndex) {
            // set index
            pageIndex = currentIndex
            
            // lazy loading
            lazyLoadPages()
            
            // callback
            delegate?.tabScrollView(self, didScrollPageTo: currentIndex)
        }
    }
    
//    open func reloadData() {
//        // setup pages
//        setupPages()
//
//        // load pages
//        lazyLoadPages()
//    }
    
    open func changePageToIndex(_ index: Int, animated: Bool) {
        activedScrollView = tabSectionScrollView
        moveToIndex(index, animated: animated)
    }
    
    open func changePageToIndex(_ index: Int, animated: Bool, completion: @escaping (() -> Void)) {
        isWaitingForPageChangedCallback = true
        pageChangedCallback = completion
        changePageToIndex(index, animated: animated)
    }
    
    // MARK: Private Methods
    fileprivate func stopScrolling() {
        tabSectionScrollView.setContentOffset(tabSectionScrollView.contentOffset, animated: false)
        contentSectionScrollView.setContentOffset(contentSectionScrollView.contentOffset, animated: false)
    }
    
    fileprivate func initWithPageIndex(_ index: Int) {
        // set pageIndex
        pageIndex = index
        prevPageIndex = pageIndex
        
        // init UI
        if (numberOfPages != 0) {
            var tabOffsetX = 0 as CGFloat
            var contentOffsetX = 0 as CGFloat
            for i in 0 ..< index {
                tabOffsetX += widthForTabAtIndex(i)
                contentOffsetX += self.frame.width
            }
            // set default position of tabs and contents
            tabSectionScrollView.contentOffset = CGPoint(x: tabOffsetX - (self.frame.width - widthForTabAtIndex(index)) / 2, y: tabSectionScrollView.contentOffset.y)
            contentSectionScrollView.contentOffset = CGPoint(x: contentOffsetX, y: contentSectionScrollView.contentOffset.y)
          //  updateTabAppearance(animated: false)
        }
    }
    
    fileprivate func currentPageIndex() -> Int {
        let width = self.frame.width
        var currentPageIndex = Int((contentSectionScrollView.contentOffset.x + (0.5 * width)) / width)
        if (currentPageIndex < 0) {
            currentPageIndex = 0
        } else if (currentPageIndex >= self.numberOfPages) {
            currentPageIndex = self.numberOfPages - 1
        }
        return currentPageIndex
    }
    
    
    fileprivate func setupPages() {
        // reset number of pages
        numberOfPages = dataSource?.numberOfPagesInTabScrollView(self) ?? 0
        
        // clear all caches
        cachedPageTabs.removeAll()
        for subview in tabSectionScrollView.subviews {
            subview.removeFromSuperview()
        }
        cachedPageContents.removeAll()
        for subview in contentSectionScrollView.subviews {
            subview.removeFromSuperview()
        }
        
        if (numberOfPages != 0) {
            // cache tabs and get the max height
            var maxTabHeight: CGFloat = 0
            for i in 0 ..< numberOfPages {
                if let tabView = tabViewForPageAtIndex(i) {
                    // get max tab height
                    if (tabView.frame.height > maxTabHeight) {
                        maxTabHeight = tabView.frame.height
                    }
                    cachedPageTabs[i] = tabView
                }
            }
            
            let tabSectionHeight = self.tabSectionHeight >= 0 ? self.tabSectionHeight : maxTabHeight
            let contentSectionHeight = self.frame.size.height - tabSectionHeight
            
            // setup tabs first, and set contents later (lazyLoadPages)
            var tabSectionScrollViewContentWidth: CGFloat = 0
            for i in 0 ..< numberOfPages {
                if let tabView = cachedPageTabs[i] {
                    tabView.frame = CGRect(
                        origin: CGPoint(
                            x: tabSectionScrollViewContentWidth,
                            y: tabSectionHeight - tabView.frame.height),
                        size: tabView.frame.size)
                    
                    // bind event
                    tabView.tag = i
                    tabView.isUserInteractionEnabled = true
                    tabView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MenuTabScrollView.tabViewDidClick(_:))))
                    tabSectionScrollView.addSubview(tabView)
                }
                tabSectionScrollViewContentWidth += widthForTabAtIndex(i)
            }
            
            // reset the fixed size of tab section
            tabSectionScrollView.frame = CGRect(x: 0, y: 0, width: self.frame.size.width, height: tabSectionHeight)
            tabSectionScrollView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(MenuTabScrollView.tabSectionScrollViewDidClick(_:))))
            tabSectionScrollView.contentInset = UIEdgeInsets(
                top: 0,
                left: (self.frame.width / 2) - (widthForTabAtIndex(0) / 2),
                bottom: 0,
                right: (self.frame.width / 2) - (widthForTabAtIndex(numberOfPages - 1) / 2))
            tabSectionScrollView.contentSize = CGSize(width: tabSectionScrollViewContentWidth, height: tabSectionHeight)
            
            // reset the fixed size of content section
            contentSectionScrollView.frame = CGRect(x: 0, y: tabSectionHeight, width: self.frame.size.width, height: contentSectionHeight)
            
         
        }
    }
    
    //タブを中央にあわせる処理
    fileprivate func lazyLoadPages() {
        if (numberOfPages != 0) {
         
            var currentContentWidth: CGFloat = 0.0
            for _ in 0 ..< numberOfPages {
                let width = self.frame.width
                currentContentWidth += width
            }
            contentSectionScrollView.contentSize = CGSize(width: currentContentWidth, height: contentSectionScrollView.frame.height)
            
            // remove older caches
            while (cachedPageContents.count > realcachedPageLimit) {
                if let (_, view) = cachedPageContents.popFirst() {
                    view.removeFromSuperview()
                }
            }
        }
    }
    
    fileprivate func moveToIndex(_ index: Int, animated: Bool) {
        if (index >= 0 && index < numberOfPages) {
            if (pagingEnabled) {
                // force stop
                stopScrolling()
                
                if (activedScrollView == nil || activedScrollView == tabSectionScrollView) {
                    activedScrollView = contentSectionScrollView
                    contentSectionScrollView.scrollRectToVisible(CGRect(
                        origin: CGPoint(x: self.frame.width * CGFloat(index), y: 0),
                        size: self.frame.size), animated: true)
                }
            }
            
            if (prevPageIndex != index) {
                prevPageIndex = index
                // callback
                delegate?.tabScrollView(self, didChangePageTo: index)
            }
        }
    }
}

public struct CacheQueue<Key: Hashable, Value> {
    
    var keys: Array<Key> = []
    var values: Dictionary<Key, Value> = [:]
    var count: Int {
        return keys.count
    }
    
    subscript(key: Key) -> Value? {
        get {
            return values[key]
        }
        set {
            // key/value pair exists, delete it first
            if let index = keys.index(of: key) {
                keys.remove(at: index)
            }
            // append key
            if (newValue != nil) {
                keys.append(key)
            }
            // set value
            values[key] = newValue
        }
    }
    
    mutating func awake(_ key: Key) {
        if let index = keys.index(of: key) {
            keys.remove(at: index)
            keys.append(key)
        }
    }
    
    mutating func popFirst() -> (Key, Value)? {
        let key = keys.removeFirst()
        if let value = values.removeValue(forKey: key) {
            return (key, value)
        } else {
            return nil
        }
    }
    
    mutating func removeAll() {
        keys.removeAll()
        values.removeAll()
    }
    
}

