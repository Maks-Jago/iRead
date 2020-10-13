//
//  IRReaderCenterViewController.swift
//  iRead
//
//  Created by zzyong on 2020/9/28.
//  Copyright © 2020 zzyong. All rights reserved.
//

import IRCommonLib

class IRReaderCenterViewController: IRBaseViewcontroller, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    var shouldHideStatusBar = true
    var book: FRBook!
    private var pageViewController: IRPageViewController!
    /// 当前阅读页VC
    private var currentReadingVC: IRReadPageViewController!
    /// 上一页
    private var previousPageView: UIView?
   
    //MARK: - Init
    
    convenience init(withBook book:FRBook) {
        self.init()
        self.book = book
    }
    
    //MARK: - Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = IRReaderConfig.pageColor
        self.updateReadPageSzie()
        self.setupPageViewController()
        self.setupNavigationBar()
        self.addNavigateTapGesture()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    override var prefersStatusBarHidden: Bool {
        return self.shouldHideStatusBar
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        pageViewController.view.frame = self.view.bounds
    }
    
    //MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, willTransitionTo pendingViewControllers: [UIViewController]) {
        
        guard let nextVc = pendingViewControllers.first else { return }
        if nextVc.isKind(of: IRReadPageViewController.self) {
            self.currentReadingVC = nextVc as? IRReadPageViewController
        }
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        
        if completed {
            if pageViewController.transitionStyle == .pageCurl {
                if let preVc = previousViewControllers.first {
                    self.previousPageView = preVc.view
                }
            }
            return
        }
        guard let preVc = previousViewControllers.first else { return }
        if preVc.isKind(of: IRReadPageViewController.self) {
            self.currentReadingVC = preVc as? IRReadPageViewController
        }
    }
    
    //MARK: - UIPageViewControllerDataSource
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        if pageViewController.transitionStyle == .pageCurl &&
           viewController.isKind(of: IRReadPageViewController.self) {
            return IRPageBackViewController.pageBackViewController(WithPageView: self.previousPageView)
        }
        
        guard let prePage = self.previousPageModel(withReadVC: self.currentReadingVC) else {
            return nil
        }
        
        IRDebugLog("page:\(prePage.pageIdx) chapter: \(prePage.chapterIdx)")
        let preVc = IRReadPageViewController.init(withPageSize: IRReaderConfig.pageSzie)
        preVc.bookPage = prePage
        return preVc
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {

        if pageViewController.transitionStyle == .pageCurl &&
           viewController.isKind(of: IRReadPageViewController.self) {
            return IRPageBackViewController.pageBackViewController(WithPageView: viewController.view)
        }
        
        guard let nextPage = self.nextPageModel(withReadVC: self.currentReadingVC) else {
            return nil
        }
        
        IRDebugLog("page:\(nextPage.pageIdx) chapter: \(nextPage.chapterIdx)")
        let nextVc = IRReadPageViewController.init(withPageSize: IRReaderConfig.pageSzie)
        nextVc.bookPage = nextPage
        return nextVc
    }
    
    
    //MARK: - Private
    
    func updateReadPageSzie() {
        
        var safeInsets = UIEdgeInsets.zero
        if #available(iOS 11.0, *) {
            if let safeAreaInsets = self.navigationController?.view.safeAreaInsets {
                safeInsets = safeAreaInsets
            }
        }
        
        let width = self.view.width - IRReaderConfig.horizontalSpacing * 2
        let height = self.view.height - safeInsets.top - safeInsets.bottom
        
        IRReaderConfig.pageSzie = CGSize.init(width: width, height: height)
    }
    
    func setupPageViewController() {
        
        if pageViewController != nil && pageViewController.parent != nil {
            pageViewController.willMove(toParent: nil)
            pageViewController.removeFromParent()
        }
        
        if IRReaderConfig.transitionStyle == .pageCurl {
            pageViewController = IRPageViewController.init(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
            pageViewController.isDoubleSided = true
        } else {
            pageViewController = IRPageViewController.init(transitionStyle: .scroll, navigationOrientation: .vertical, options: nil)
        }
        
        pageViewController.delegate = self
        pageViewController.dataSource = self
        self.addChild(pageViewController)
        pageViewController.didMove(toParent: self)
        self.view.addSubview(pageViewController.view)
        
        currentReadingVC = IRReadPageViewController.init(withPageSize: IRReaderConfig.pageSzie)
        if let firstCahpter = book.tableOfContents.first {
            let currentChapter = IRBookChapter.init(withTocRefrence: firstCahpter, chapterIndex: 0)
            currentReadingVC.bookPage = currentChapter.pageList?.first
        }
        pageViewController.setViewControllers([currentReadingVC], direction: .forward, animated: false, completion: nil)
    }
    
    func setupNavigationBar() {
        self.setupLeftBackBarButton()
    }
    
    func previousPageModel(withReadVC readVc: IRReadPageViewController) -> IRBookPage? {
        
        var pageModel: IRBookPage? = nil
        
        guard var pageIndex = readVc.bookPage?.pageIdx else { return pageModel }
        guard var chapterIndex = readVc.bookPage?.chapterIdx else { return pageModel }
        var currentChapter: IRBookChapter? = nil
        // 后续解析优化
        if let currentRefrence = self.book.tableOfContents?[chapterIndex] {
            currentChapter = IRBookChapter.init(withTocRefrence: currentRefrence, chapterIndex: chapterIndex)
        }

        if pageIndex > 0 {
            pageIndex -= 1;
            pageModel = currentChapter?.pageList?[pageIndex]
        } else {
            if chapterIndex > 0 {
                chapterIndex -= 1;
                if let preRefrence = self.book.tableOfContents?[chapterIndex] {
                    currentChapter = IRBookChapter.init(withTocRefrence: preRefrence, chapterIndex: chapterIndex)
                }
                pageModel = currentChapter?.pageList?.last
            }
        }
        
        return pageModel
    }
    
    func nextPageModel(withReadVC readVc: IRReadPageViewController) -> IRBookPage? {
        
        var pageModel: IRBookPage? = nil
        
        guard var pageIndex = readVc.bookPage?.pageIdx else { return pageModel }
        guard var chapterIndex = readVc.bookPage?.chapterIdx else { return pageModel }
        
        var currentChapter: IRBookChapter? = nil
        // 后续解析优化
        if let currentRefrence = self.book.tableOfContents?[chapterIndex] {
            currentChapter = IRBookChapter.init(withTocRefrence: currentRefrence, chapterIndex: chapterIndex)
        }

        let pageCount = currentChapter?.pageList?.count ?? 0
        if pageIndex + 1 < pageCount {
            pageIndex += 1;
            pageModel = currentChapter?.pageList?[pageIndex]
        } else {
            if chapterIndex + 1 < self.book.tableOfContents.count {
                chapterIndex += 1;
                if let nextRefrence = self.book.tableOfContents?[chapterIndex] {
                    currentChapter = IRBookChapter.init(withTocRefrence: nextRefrence, chapterIndex: chapterIndex)
                }
                pageModel = currentChapter?.pageList?.first
            }
        }
        
        return pageModel
    }
    
    //MARK: - Gesture
    
    func addNavigateTapGesture() {
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(didNavigateTapGestureClick(tapGesture:)))
        self.view.addGestureRecognizer(tap)
    }
    
    @objc func didNavigateTapGestureClick(tapGesture: UITapGestureRecognizer) {
        self.shouldHideStatusBar = !self.shouldHideStatusBar;
        self.navigationController?.setNavigationBarHidden(self.shouldHideStatusBar, animated: true)
    }
}
