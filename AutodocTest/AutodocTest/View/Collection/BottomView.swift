//
//  BottomView.swift
//  AutodocTest
//
//  Created by Даниил Мурыгин on 20.05.2024.
//

import UIKit
import Combine

class BottomView: UIView{
    let leftButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.backgroundColor = .white
        view.setImage(UIImage(systemName: "arrowshape.backward"), for: .normal)
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        return view
    }()
    let rightButton: UIButton = {
        let view = UIButton()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.backgroundColor = .white
        let image = UIImage(systemName: "arrowshape.right")?.withTintColor(.black, renderingMode: .alwaysTemplate)
        view.setImage(image, for: .normal)
        view.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]
        return view
    }()
    let centerLabel: UILabel = {
        let title = UILabel()
        title.translatesAutoresizingMaskIntoConstraints = false
        title.textAlignment = .center
        
        return title
    }()
    
    let activityIndicator: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .large)
        view.color = .black
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var subscribe = Set<AnyCancellable>()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        
        $index
            .receive(on: DispatchQueue.main)
            .sink { value in
                self.centerLabel.text = "\(value)"
            }
            .store(in: &subscribe)
    }
    
    
    
    @Published var index: UInt = 1
    
    func setupViews(){
        self.addSubview(self.leftButton)
        self.addSubview(self.rightButton)
        self.addSubview(self.centerLabel)
        self.addSubview(self.activityIndicator)
        index = 1
    }
    
    func setupConstraints(){
        NSLayoutConstraint.activate([
            centerLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            centerLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            
            leftButton.centerYAnchor.constraint(equalTo: centerLabel.centerYAnchor),
            leftButton.trailingAnchor.constraint(equalTo: centerLabel.leadingAnchor,constant: -5),
            leftButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 0),
            leftButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            leftButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            
            rightButton.leadingAnchor.constraint(equalTo: centerLabel.trailingAnchor,constant: 5),
            rightButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: 0),
            rightButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 0),
            rightButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: 0),
            rightButton.centerYAnchor.constraint(equalTo: centerLabel.centerYAnchor),
            
            
            activityIndicator.centerXAnchor.constraint(equalTo: centerLabel.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: centerLabel.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
