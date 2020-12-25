//
//  IRHomeViewController.swift
//  iRead
//
//  Created by zzyong on 2020/9/25.
//  Copyright © 2020 zzyong. All rights reserved.
//

import IRCommonLib

class IRHomeViewController: IRBaseViewcontroller {
    
    var collectionView: UICollectionView!
    
    var statusBarBlurView: UIVisualEffectView = {
        let blur = UIBlurEffect.init(style: .light)
        let effectView = UIVisualEffectView.init(effect: blur)
        return effectView
    }()
    
    let sectionEdgeInsetLR: CGFloat = {
        return UIScreen.main.bounds.width > 375 ? 20 : 15
    }()
    
    var homeList: NSArray = {
        let taskModel = IRHomeTaskModel()
        let readingModel = IRHomeCurrentReadingModel()
#if DEBUG
        taskModel.progress = Double((arc4random() % 100)) / 100.0
        readingModel.isReading = (arc4random() % 100) > 50
        readingModel.bookName = "我是书名～～"
        readingModel.author = "佚名"
        readingModel.progress = Int(arc4random() % 100)
#endif
        return NSArray.init(objects: taskModel, readingModel)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // statusBarBlurView
        view.addSubview(statusBarBlurView)
        setupCollectionView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if #available(iOS 11.0, *) {
            navigationController?.navigationBar.prefersLargeTitles = false
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        statusBarBlurView.frame = UIApplication.shared.statusBarFrame
    }
    
    @available(iOS 11.0, *)
    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateCollectionViewTopInset()
    }
    
    func updateCollectionViewTopInset() {
        var topInsert = UIApplication.shared.statusBarFrame.height
        if #available(iOS 11.0, *) {
            collectionView.contentInsetAdjustmentBehavior = .never
            if let safeInsets = UIApplication.shared.keyWindow?.safeAreaInsets {
                topInsert = safeInsets.top
            }
        }
        collectionView.contentInset = UIEdgeInsets(top: topInsert, left: 0, bottom: 0, right: 0)
    }
    
    private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 30
        flowLayout.minimumInteritemSpacing = 0
        collectionView = UICollectionView.init(frame: self.view.bounds, collectionViewLayout: flowLayout)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .hexColor("EEEEEE")
        collectionView.alwaysBounceVertical = true
        collectionView.register(IRHomeTaskCell.self, forCellWithReuseIdentifier: "IRHomeTaskCell")
        collectionView.register(IRHomeCurrentReadingCell.self, forCellWithReuseIdentifier: "IRHomeCurrentReadingCell")
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "UICollectionViewCell")
        view.insertSubview(collectionView, belowSubview: statusBarBlurView)
    }
}

// MARK: - UICollectionView
extension IRHomeViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return homeList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellModel = homeList.object(at: indexPath.item)
        var cell: UICollectionViewCell
        if cellModel is IRHomeTaskModel {
            let taskCell: IRHomeTaskCell = collectionView.dequeueReusableCell(withReuseIdentifier: "IRHomeTaskCell", for: indexPath) as! IRHomeTaskCell
            taskCell.taskModel = cellModel as? IRHomeTaskModel
            cell = taskCell
        } else if cellModel is IRHomeCurrentReadingModel {
            let readingCell: IRHomeCurrentReadingCell = collectionView.dequeueReusableCell(withReuseIdentifier: "IRHomeCurrentReadingCell", for: indexPath) as! IRHomeCurrentReadingCell
            readingCell.readingModel = cellModel as? IRHomeCurrentReadingModel
            cell = readingCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "UICollectionViewCell", for: indexPath)
        }
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let cellModel = homeList.object(at: indexPath.item)
        let cellWidth = collectionView.width - sectionEdgeInsetLR * 2
        var cellSize: CGSize
        if cellModel is IRHomeTaskModel {
            cellSize = CGSize.init(width: cellWidth, height: IRHomeTaskCell.cellHeight(with: cellWidth))
        } else if cellModel is IRHomeCurrentReadingModel {
            cellSize = CGSize(width: cellWidth, height: 185.5)
        } else {
            cellSize = CGSize.zero
        }
        return cellSize
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: 10, left: sectionEdgeInsetLR, bottom: 10, right: sectionEdgeInsetLR)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
}
