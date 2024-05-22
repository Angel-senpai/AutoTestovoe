//
//  CollectionView.swift
//  AutodocTest
//
//  Created by Даниил Мурыгин on 18.05.2024.
//

import UIKit
import Combine

class CollectionView: UIViewController {
    
    typealias DataSource = UICollectionViewDiffableDataSource<Int, NewsModelElement>
    
    var model = CollectionViewModel()
    
    private var news: [NewsModelElement] = []
    
    @Published var cancellables: Set<AnyCancellable> = []
    
    var collectionView: UICollectionView?
    var bottomView = BottomView()
    var dataSource: DataSource?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        configureHierarchy()
        configureDataSource()
        
        model.$news
            .compactMap{$0?.news}
            .receive(on: DispatchQueue.main)
            .sink {[weak self] value in
                guard let self = self else {return}
                self.news = value
                self.updateSections(self.news)
            }.store(in: &cancellables)
        
        model.$state
            .receive(on: DispatchQueue.main)
            .sink {[weak self] value in
                guard let self = self else {return}
                if value == .loading{
                    self.bottomView.centerLabel.isHidden = true
                    self.bottomView.activityIndicator.startAnimating()
                    self.collectionView?.isUserInteractionEnabled = false
                }else{
                    self.bottomView.centerLabel.isHidden = false
                    self.collectionView?.isUserInteractionEnabled = true
                    self.bottomView.activityIndicator.stopAnimating()
                }
            }.store(in: &cancellables)
        
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        gesture.direction = .left
        let gesture1 = UISwipeGestureRecognizer(target: self, action: #selector(didSwipe(_:)))
        gesture1.direction = .right
        collectionView?.addGestureRecognizer(gesture)
        collectionView?.addGestureRecognizer(gesture1)
        
        
        bottomView = BottomView()
        bottomView.backgroundColor = .white
        bottomView.layer.cornerRadius = 20
        view.addSubview(bottomView)
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        
        bottomView.leftButton.addTarget(self, action: #selector(leftAction(_:)), for: .touchUpInside)
        bottomView.rightButton.addTarget(self, action: #selector(rightAction(_:)), for: .touchUpInside)
        
        NSLayoutConstraint.activate([
            bottomView.widthAnchor.constraint(equalToConstant: view.frame.width * 0.4),
            bottomView.heightAnchor.constraint(equalToConstant: view.frame.height * 0.05),
            bottomView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 10),
            bottomView.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    @objc private func leftAction(_ sender: UIButton){
        if model.state != .loading{
            if model.currentPage == 1{
                bottomView.index = model.currentPage
                return
            }
            let index = model.currentPage - 1
            model.currentPage = index
            bottomView.index = index
        }
    }
    
    @objc private func rightAction(_ sender: UIButton){
        if model.state != .loading{
            let index = model.currentPage + 1
            model.currentPage = index
            bottomView.index = index
        }
    }
    
    @objc private func didSwipe(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction{
            case .left:
                rightAction(bottomView.rightButton)
            case .right:
                leftAction(bottomView.leftButton)
            default:
                break
        }
        
    }

}


extension CollectionView: UICollectionViewDelegate{
    
    func updateSections(_ elements: [NewsModelElement]){
        if elements.isEmpty{return}
        var snapshot = NSDiffableDataSourceSnapshot<Int, NewsModelElement>()
        var identifierOffset = 0
        let itemsPerSection = 15
        for section in 0..<1 {
            
            snapshot.appendSections([section])
            let maxIdentifier = identifierOffset + itemsPerSection
            var arr: [NewsModelElement] = []
            
            for i in identifierOffset..<maxIdentifier{
                arr.append(elements[i])
            }
            
            snapshot.appendItems(arr)
            identifierOffset += itemsPerSection
        }
        collectionView?.contentOffset = .init(x: 0, y: -view.safeAreaInsets.top)
        collectionView?.contentInset.bottom = 30
        dataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    
    
    func configureHierarchy() {
        let collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: createLayout())
        self.collectionView = collectionView
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.backgroundColor = .systemMint
        view.addSubview(collectionView)
        collectionView.delegate = self
    }
     
    func configureDataSource() {
        guard let collectionView = collectionView else {return}
        dataSource = DataSource(
            collectionView: collectionView,
            cellProvider: { (collectionView, indexPath, news) -> UICollectionViewCell? in
                switch news.category{
                case .corpnews:
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: NewsCell.reuseIdentifier,
                        for: indexPath) as? NewsCell
                    cell?.model = news
                    cell?.backgroundColor = .white
                    cell?.layer.cornerRadius = 22
                    return cell
                case .autonews:
                    let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: NewsImageCell.reuseIdentifier,
                        for: indexPath) as? NewsImageCell
                    cell?.model = news
                    cell?.backgroundColor = .white
                    cell?.layer.cornerRadius = 22
                    return cell
                }
                
            })
        
        collectionView.register(NewsCell.self, forCellWithReuseIdentifier: NewsCell.reuseIdentifier)
        collectionView.register(NewsImageCell.self, forCellWithReuseIdentifier: NewsImageCell.reuseIdentifier)
    }
        
        
        
        func createLayout() -> UICollectionViewLayout {
            let layout = UICollectionViewCompositionalLayout {
                (sectionIndex: Int, layoutEnvironment: NSCollectionLayoutEnvironment) -> NSCollectionLayoutSection? in
                
                let item = NSCollectionLayoutItem(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .fractionalHeight(1)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 10, leading: 20, bottom: 10, trailing: 20)
                
                let hdiff = layoutEnvironment.container.contentSize.height < layoutEnvironment.container.contentSize.width ? 0.8: 0.3
                
                let containerGroup = NSCollectionLayoutGroup.horizontal(
                    layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1),
                                                       heightDimension: .fractionalHeight(hdiff)),
                    subitems: [item])
                
                let section = NSCollectionLayoutSection(group: containerGroup)
                //section.orthogonalScrollingBehavior = .continuous
                
                return section
                
            }
            return layout
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? NewsCellProtocol else {return}
        guard let animateCell = collectionView.cellForItem(at: indexPath) else {return}
        
        if !animateCell.isHighlighted{
            UIView.animate(withDuration: 0.2, delay: 0, options: [.autoreverse]) {
                animateCell.transform = animateCell.transform.scaledBy(x: 0.98, y: 0.98)
            }completion: { _ in
                animateCell.transform = CGAffineTransform.identity
            }
        }
        
        guard let model = cell.getModel() else {
            return
        }
        let controller = DetailsView(model: model)
        //controller.modalPresentationStyle = .popover
        
        present(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {return}
        UIView.animate(withDuration: 0.2, delay: 0) {
            cell.transform = cell.transform.scaledBy(x: 0.98, y: 0.98)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) else {return}
        UIView.animate(withDuration: 0.2, delay: 0) {
            cell.transform = CGAffineTransform.identity
        }
    }
}
