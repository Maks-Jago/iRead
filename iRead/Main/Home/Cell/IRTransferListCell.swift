//
//  IRTransferListCell.swift
//  iRead
//
//  Created by zzyong on 2022/3/5.
//  Copyright © 2022 iread.com. All rights reserved.
//

import UIKit
import SnapKit

class IRTransferListCell: UICollectionViewCell {
    
    static let bookCoverH: CGFloat = 70
    static let bookContentH: CGFloat = bookCoverH / bookCoverScale
    static let cellHeight: CGFloat = 153.5 + bookContentH
    let pogressH: CGFloat = 18
    var bookContentView: UIView?
    var bookCover: UIImageView?
    var bookNameLabel: UILabel?
    var authorLabel: UILabel?
    var progressLabel: UILabel?
    var emptyLabel: UILabel?
    var titleLabel = UILabel()
    weak var delegate: IRCurrentReadingDelegate?
    
    lazy var textCover: IRTextCoverView = {
        let bg = IRTextCoverView()
        guard let bookCover = bookCover else { return bg }
        bookCover.addSubview(bg)
        bg.snp.makeConstraints { make in
            make.edges.equalTo(bookCover)
        }
        bg.fontScale = 0.7
        return bg
    }()
    
    var readingBtn = UIButton.init(type: .custom)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if bookContentView != nil {
            let progressY = authorLabel!.frame.maxY + 10
            let progressW = ((progressLabel!.text ?? "") as NSString).size(withAttributes: [.font: progressLabel!.font!]).width + 12
            progressLabel!.frame = CGRect(x: authorLabel!.x, y: progressY, width: progressW, height: pogressH)
        }
    }
    
    var readingModel: IRCurrentReadingModel? {
        didSet {
            if let isReading = readingModel?.isReading, isReading {
                addBookContentViewIfNeeded()
                emptyLabel?.isHidden = true
                bookContentView?.isHidden = false
//                readingBtn.setTitle("继续阅读", for: .normal)
                readingBtn.setTitle("continue reading", for: .normal)

                bookCover?.image = readingModel?.coverImage
                textCover.isHidden = readingModel?.coverImage != nil
                if !textCover.isHidden {
                    textCover.setBookName(readingModel?.bookName, authorName: readingModel?.author)
                } else {
                    textCover.setBookName(nil, authorName: nil)
                }
                
                bookNameLabel?.text = readingModel?.bookName
                authorLabel?.text = readingModel?.author ?? "Anonymous"//"佚名"
                
                updateProgressLabelText()
            } else {
                addEmptyLabelIfNeeded()
                bookContentView?.isHidden = true
                emptyLabel?.isHidden = false
//                readingBtn.setTitle("添加图书", for: .normal)
                readingBtn.setTitle("Add books", for: .normal)
            }
        }
    }
    
    func updateProgressLabelText() {
        var textColor: UIColor?
        var bgColor: UIColor?
        var textAlignment: NSTextAlignment?
        if let progress = readingModel?.progress {
            if progress <= 0 {
                progressLabel!.text = "Add" //"新增"
                bgColor = UIColor.rgba(255, 156, 0, 1)
                textAlignment = .center
                textColor = .white
            } else if progress >= 100 {
                progressLabel!.text = "finished" //"已读完"
            } else {
                progressLabel!.text = "\(progress)%"
            }
        } else {
            progressLabel!.text = ""
        }
        progressLabel!.textColor = textColor ?? UIColor.hexColor("666666")
        progressLabel!.textAlignment = textAlignment ?? .left
        progressLabel!.backgroundColor = bgColor ?? UIColor.clear
    }
    
    func addEmptyLabelIfNeeded() {
        if emptyLabel != nil {
            return
        }
        let emptyLabel = UILabel()
        self.emptyLabel = emptyLabel
        emptyLabel.numberOfLines = 0
        emptyLabel.font = .systemFont(ofSize: 16)
        emptyLabel.textColor = .hexColor("666666")
        emptyLabel.text = "Dear, you don't have any books you're reading at the moment, go and add a good book to see~" //"亲，你暂无正在阅读的图书，快去添加一本好书看看吧～"
        addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.right.equalTo(self).offset(-20)
            make.bottom.equalTo(readingBtn.snp.top).offset(-20)
        }
    }
    
    func addBookContentViewIfNeeded() {
        if bookContentView != nil {
            return
        }
        
        bookContentView = UIView()
        addSubview(bookContentView!)
        bookContentView!.snp.makeConstraints { (make) in
            make.left.equalTo(self).offset(20)
            make.top.equalTo(self.titleLabel.snp.bottom).offset(20)
            make.right.equalTo(self).offset(-20)
            make.height.equalTo(IRCurrentReadingCell.bookContentH)
        }
        
        let bookCover = UIImageView()
        self.bookCover = bookCover
        bookCover.contentMode = .scaleAspectFit
        bookCover.layer.cornerRadius = 3
        bookCover.layer.masksToBounds = true
        bookContentView!.addSubview(bookCover)
        bookCover.snp.makeConstraints { (make) in
            make.left.top.bottom.equalTo(bookContentView!)
            make.width.equalTo(IRCurrentReadingCell.bookCoverH)
        }
        
        let authorLabel = UILabel()
        self.authorLabel = authorLabel
        authorLabel.font = .systemFont(ofSize: 15)
        authorLabel.textColor = .hexColor("333333")
        bookContentView!.addSubview(authorLabel)
        authorLabel.snp.makeConstraints { (make) in
            make.centerY.right.equalTo(bookContentView!)
            make.left.equalTo(bookCover.snp.right).offset(10)
        }
        
        let titleLabel = UILabel()
        self.bookNameLabel = titleLabel
        titleLabel.numberOfLines = 1
        titleLabel.font = .systemFont(ofSize: 18)
        titleLabel.textColor = .black
        bookContentView!.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(authorLabel.snp.top).offset(-10)
            make.left.equalTo(authorLabel)
            make.right.equalTo(bookContentView!)
        }
        
        let progressLabel = UILabel()
        self.progressLabel = progressLabel
        progressLabel.font = .systemFont(ofSize: 12)
        progressLabel.textColor = .hexColor("999999")
        progressLabel.layer.cornerRadius = pogressH * 0.5
        progressLabel.layer.masksToBounds = true
        bookContentView!.addSubview(progressLabel)
    }
    
    func setupSubviews() {
        backgroundColor = .white
        layer.cornerRadius = 10
        
        titleLabel.textColor = .black
        titleLabel.text = "Transfer List" //"传输列表"
        titleLabel.font = .boldSystemFont(ofSize: 20)
        addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.height.equalTo(24)
            make.top.left.equalTo(self).offset(20)
        }
        
        let readingBtnH: CGFloat = 49.5
        readingBtn.addTarget(self, action: #selector(didClickReadingButton), for: .touchUpInside)
        readingBtn.titleLabel?.font = .boldSystemFont(ofSize: 16)
        readingBtn.backgroundColor = .black
        readingBtn.layer.cornerRadius = readingBtnH / 2
        addSubview(readingBtn)
        readingBtn.snp.makeConstraints { (make) in
            make.height.equalTo(readingBtnH)
            make.bottom.equalTo(self).offset(-20)
            make.left.equalTo(self).offset(20)
            make.right.equalTo(self).offset(-20)
        }
    }
    
    @objc func didClickReadingButton() {
        guard let readingModel = readingModel else { return }
        if readingModel.isReading {
            delegate?.currentReadingCellDidClickKeepReading()
        } else {
            delegate?.currentReadingCellDidClickFindBook()
        }
    }
}
