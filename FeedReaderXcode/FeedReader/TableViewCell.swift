//
//  TableViewCell.swift
//  FeedReader
//
//  Created by Sergey on 21/02/2019.
//  Copyright © 2019 Sergey. All rights reserved.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    let screenSize: CGRect = UIScreen.main.bounds
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI(){
        addSubview(titleLabel)
        addSubview(dateLabel)
        addSubview(dataLabel)
        addSubview(thumbImage)
        
       
    }
    
    
    lazy var titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.frame = CGRect(x: screenSize.width * 0.46, y: 5, width: screenSize.width * 0.52, height: screenSize.height * 0.06)
        titleLabel.textColor = UIColor.black
        titleLabel.font = UIFont.systemFont(ofSize: 15.0 , weight: .bold)
        titleLabel.textAlignment = .left
        titleLabel.numberOfLines = 2
        return titleLabel
    }()
    
    
    lazy var dataLabel: UILabel = {
        let dataLabel = UILabel()
        dataLabel.frame = CGRect(x: screenSize.width * 0.46, y: screenSize.height * 0.07, width: screenSize.width * 0.52 , height: screenSize.height * 0.06)
        dataLabel.textColor = UIColor.black
        dataLabel.font = UIFont.systemFont(ofSize: 10.0)
        dataLabel.textAlignment = .left
        dataLabel.numberOfLines = 3
        return dataLabel
    }()
    
    lazy var dateLabel: UILabel = {
        let dateLabel = UILabel()
        dateLabel.frame = CGRect(x: screenSize.width * 0.46, y: screenSize.height * 0.14, width: screenSize.width * 0.52 , height: screenSize.height * 0.02)
        dateLabel.textColor = UIColor.gray
        dateLabel.font = UIFont.systemFont(ofSize: 10.0)
        dateLabel.textAlignment = .right
        dateLabel.numberOfLines = 3
        return dateLabel
    }()
    
    lazy var thumbImage: UIImageView = {
        let thumbImage = UIImageView()
        thumbImage.frame = CGRect(x: screenSize.width * 0.02, y: 5, width: screenSize.width * 0.42, height: screenSize.height * 0.15)
        thumbImage.contentMode = .scaleToFill
        return thumbImage
    }()
    
}
