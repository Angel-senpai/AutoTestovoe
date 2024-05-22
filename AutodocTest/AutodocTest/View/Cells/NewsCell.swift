//
//  NewsCell.swift
//  AutodocTest
//
//  Created by Даниил Мурыгин on 18.05.2024.
//

import UIKit
import Combine

protocol NewsCellProtocol{
    func getModel() -> NewsModelElement?
}

class NewsCell: UICollectionViewCell{
    static let reuseIdentifier = "test-cell-reuse-identifier"
    
    @Published var model: NewsModelElement?
    var cancelable = Set<AnyCancellable>()
    
    let titleLabel: UILabel = {
        
        let title = UILabel()
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .center
        return title
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        $model
            .receive(on: DispatchQueue.main)
            .sink { element in
                self.titleLabel.text = element?.title
            }.store(in: &cancelable)
        configurate()
    }
    
    func configurate(){
        contentView.addSubview(titleLabel)
        titleLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        let inset = CGFloat(10)
        
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: inset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -inset),
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: inset),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -inset)
            ])
        
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        model = nil
        titleLabel.text = ""
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
extension NewsCell: NewsCellProtocol{
    func getModel() -> NewsModelElement? {
        return model
    }
}
