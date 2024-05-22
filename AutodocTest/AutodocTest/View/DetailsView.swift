//
//  DetailsView.swift
//  AutodocTest
//
//  Created by Даниил Мурыгин on 20.05.2024.
//

import UIKit
import Combine

class DetailsView: UIViewController{
    
    var cellModel: NewsModelElement?
    var model = DetailsViewModel()
    @Published var cancellables: Set<AnyCancellable> = []
    
    let imageView: UIImageView = {
       let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleToFill
        return imageView
    }()
    let detailsView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let titleLabel: UILabel = {
        
        let title = UILabel()
        title.numberOfLines = 0
        title.lineBreakMode = .byWordWrapping
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .center
        title.textColor = .black
        title.font = UIFont.preferredFont(forTextStyle: .title1)
        return title
    }()
    
    let descriptionLabel: UITextView = {
        
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textAlignment = .left
        textView.textColor = .black
        textView.font = UIFont.preferredFont(forTextStyle: .title2)
        textView.contentInset.bottom = 20
        textView.showsVerticalScrollIndicator = false
        return textView
    }()

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init() {
        self.init(model: nil)
    }
    
    init(model: NewsModelElement?) {
        self.cellModel = model
        self.model.currentNews = model?.url ?? ""
        super.init(nibName: nil, bundle: nil)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task{
            await setupViews()
            
            setupConstraints()
        }
        
        model.$news
            .map{
                $0?.text?.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            }
            .receive(on: DispatchQueue.main)
            .sink { value in
                guard let value = value else {return}
                self.descriptionLabel.text = value.attributedHtmlString?.string
            }.store(in: &cancellables)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    @MainActor
    func setupViews() async{
        
        if let url = URL(string: (cellModel?.titleImageUrl) ?? ""){
            if let data = try? await DownloadHelper.shared.download(url){
                imageView.image = UIImage(data: data)
            }
        }
        
        titleLabel.text = cellModel?.title
    }
    

    
    func setupConstraints(){
        view.addSubview(imageView)
        view.addSubview(detailsView)
        detailsView.addSubview(titleLabel)
        detailsView.addSubview(descriptionLabel)
        
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),
            imageView.widthAnchor.constraint(equalTo: view.widthAnchor),
            
            detailsView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            detailsView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -20),
            detailsView.widthAnchor.constraint(equalTo: view.widthAnchor),
            detailsView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: detailsView.topAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: detailsView.centerXAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 1),
            titleLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -1),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5),
            descriptionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            descriptionLabel.centerXAnchor.constraint(equalTo: detailsView.centerXAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: detailsView.leadingAnchor, constant: 30),
            descriptionLabel.trailingAnchor.constraint(equalTo: detailsView.trailingAnchor, constant: -30),
            
            
        ])
    }
}
