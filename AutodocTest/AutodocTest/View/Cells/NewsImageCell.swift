//
//  NewsImageCell.swift
//  AutodocTest
//
//  Created by Даниил Мурыгин on 18.05.2024.
//

import UIKit
import Combine

enum LoadingState {
    case notLoading
    case loading
    case loaded
}

class NewsImageCell: UICollectionViewCell{
    
    static let reuseIdentifier = "test-image-cell-reuse-identifier"
    
    @Published var model: NewsModelElement?
    var cancelable = Set<AnyCancellable>()
    var downloadTask: Task<(), Never>?
    var gradientConfigurated = false
    
    var loadingState: LoadingState = .notLoading {
        didSet {
            switch loadingState {
            case .notLoading:
                activityIndicator.stopAnimating()
            case .loading:
                imageView.image = .none
                activityIndicator.startAnimating()
            case .loaded:
                activityIndicator.stopAnimating()
            }
        }
    }
    
    let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let imageView: UIImageView = {
        let imageV = UIImageView()
        imageV.backgroundColor = UIColor.white
        imageV.contentMode = .scaleAspectFill
        imageV.translatesAutoresizingMaskIntoConstraints = false
        imageV.layer.cornerRadius = 20
        imageV.clipsToBounds = true
        return imageV
    }()
    
    
    let titleLabel: UILabel = {
        let title = UILabel()
        title.lineBreakMode = .byWordWrapping
        title.numberOfLines = 2
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .natural
        title.textColor = .white
        title.font = UIFont.preferredFont(forTextStyle: .caption1)
        title.adjustsFontForContentSizeCategory = true
        return title
    }()
    
    let tagLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .left
        title.textColor = .white
        title.font = UIFont.preferredFont(forTextStyle: .footnote)
        return title
    }()
    
    let gradientView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let tagView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black.withAlphaComponent(0.6)
        view.layer.cornerRadius = 9
        view.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner, .layerMinXMaxYCorner]
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        $model
            .receive(on: DispatchQueue.main)
            .sink {[weak self] element in
                self?.setTask()
                self?.titleLabel.text = element?.title
                self?.tagLabel.text = element?.categoryType
            }.store(in: &cancelable)
        
        configurate()
    }
    
    private func setTask(){
        loadingState = .loading
        downloadTask = Task(priority: .userInitiated){
            let imageData = try? await DownloadHelper.shared.download(URL(string: model?.titleImageUrl ?? ""))
            if let imageData = imageData{
                await setImage(imageData)
            }
        }
    }
    
    func configurate(){
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        tagView.addSubview(tagLabel)
        
        imageView.addSubview(activityIndicator)
        imageView.addSubview(tagView)
        imageView.addSubview(gradientView)
        
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 25),
            titleLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            titleLabel.topAnchor.constraint(equalTo: gradientView.topAnchor, constant: 2),
            titleLabel.bottomAnchor.constraint(equalTo: gradientView.bottomAnchor, constant: -1),
            
            tagView.widthAnchor.constraint(equalTo: tagLabel.widthAnchor, multiplier: 1.1),
            tagView.heightAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 0.1),
            tagView.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 0),
            tagView.trailingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 0),
            
            tagLabel.centerXAnchor.constraint(equalTo: tagView.centerXAnchor),
            tagLabel.centerYAnchor.constraint(equalTo: tagView.centerYAnchor),
            
            gradientView.widthAnchor.constraint(equalTo: imageView.widthAnchor),
            gradientView.heightAnchor.constraint(equalTo: imageView.heightAnchor, multiplier: 0.2),
            gradientView.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            gradientView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            
            activityIndicator.centerXAnchor.constraint(equalTo: imageView.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: imageView.centerYAnchor)
            ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientConf()
    }
    
    private func gradientConf(){
        let gradientLayer: CAGradientLayer = CAGradientLayer()
        gradientLayer.frame.size = self.gradientView.bounds.size
        gradientLayer.colors = [UIColor.black.withAlphaComponent(0.3).cgColor,UIColor.black.withAlphaComponent(1).cgColor]
        //Use diffrent colors
        gradientView.layer.sublayers?.remove(at: 0)
        gradientView.layer.insertSublayer(gradientLayer, at: 0)
        
    }
    
    
    @MainActor
    private func setImage(_ imageData: Data) async{
        imageView.image = UIImage(data: imageData)
        loadingState = .loaded
        layoutSubviews()
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = .none
        titleLabel.text = ""
        tagLabel.text = ""
        loadingState = .notLoading
        if downloadTask?.isCancelled == false{
            downloadTask?.cancel()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension NewsImageCell: NewsCellProtocol{
    func getModel() -> NewsModelElement? {
        return model
    }
}
