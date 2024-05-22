//
//  DetailsViewModel.swift
//  AutodocTest
//
//  Created by Даниил Мурыгин on 22.05.2024.
//

import Foundation
import Combine

class DetailsViewModel: ObservableObject{
    @Published var news: NewsModelElement?
    @Published var currentNews: String = ""
    @Published var cancellables: Set<AnyCancellable> = []
    
    init() {
        
        $currentNews
            .sink(receiveValue: {value in
                if value.isEmpty{return}
                self.getNews(value)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { completion in
                        switch completion{
                            case .finished: print("DetailsViewModel:: getNews() -> finished ")
                            case .failure(let error): print("DetailsViewModel:: getNews() -> Error \(error) ")
                        }
                        }) { model in
                            
                        self.news = model
                    }
                    .store(in: &self.cancellables)
            })
            .store(in: &cancellables)
    
    }
    
    private func getNews(_ news: String) -> Future<NewsModelElement, Error>{
        return ModelLoader().modelPublisher(for: getURL(news))
    }
    
    private func getURL(_ news: String) -> URL?{
        URL(string: "https://webapi.autodoc.ru/api/news/item/\(news)")
    }
}

extension String {
    var attributedHtmlString: NSAttributedString? {
        try? NSAttributedString(
            data: Data(utf8),
            options: [
                .documentType: NSAttributedString.DocumentType.html,
                .characterEncoding: String.Encoding.utf8.rawValue
            ],
            documentAttributes: nil
        )
    }
}
