//
//  CollectionViewModel.swift
//  AutodocTest
//
//  Created by Даниил Мурыгин on 18.05.2024.
//

import Foundation
import Combine

class CollectionViewModel: ObservableObject{
    enum Section {case news}
    
    enum State{
        case loaded
        case loading
    }
    
    @Published var state: State = .loading
    @Published var news: NewsModel?
    @Published var currentPage: UInt = 1
    @Published var cancellables: Set<AnyCancellable> = []
    
    private var newsCount = 15

    
    
    init() {
        
        $currentPage
            .sink(receiveValue: {value in
                self.state = .loading
                self.getNews(value)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion{
                            case .finished: print("CollectionViewModel:: getNews() -> finished ")
                            case .failure(let error): print("CollectionViewModel:: getNews() -> Error \(error) ")
                        }
                        self.state = .loaded
                        }) { model in
                            
                        self.news = model
                    }
                    .store(in: &self.cancellables)
            })
            .store(in: &cancellables)
    
    }
    
    private func getNews(_ page: UInt) -> Future<NewsModel, Error>{
        return ModelLoader().modelPublisher(for: getURL(page))
    }
    
    private func getURL(_ page: UInt) -> URL?{
        URL(string: "https://webapi.autodoc.ru/api/news/\(page)/\(newsCount)")
    }
    
    private func getURL(_ news: String) -> URL?{
        URL(string: "https://webapi.autodoc.ru/api/news/item/\(news)")
    }
}
