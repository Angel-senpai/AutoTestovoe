//
//  NewsModel.swift
//  AutodocTest
//
//  Created by Даниил Мурыгин on 18.05.2024.
//

import Foundation

struct NewsModel: Codable{
    let news: [NewsModelElement]
}

struct NewsModelElement: Codable, Hashable{
    let id: Int
    let title: String
    let description: String
    let publishedDate: String
    let text: String?
    let url: String
    let fullUrl: String
    let titleImageUrl: String?
    let categoryType: String
    
    var category: CategoryType {
        switch categoryType{
        case "Новости компании":
            return .corpnews
        default:
            return .autonews
        }
    }
}

enum CategoryType{
    case autonews
    case corpnews
}
