//
//  ModelLoader.swift
//  AutodocTest
//
//  Created by Даниил Мурыгин on 18.05.2024.
//

import Combine
import Foundation

final class ModelLoader<Model: Decodable>{
    
    func loadModel(from url: URL?) async throws -> Model{
        let data = try await DownloadHelper.shared.download(url) ?? Data()
        
        return try JSONDecoder().decode(Model.self, from: data)
    }
    
    func modelPublisher(for url: URL?) -> Future<Model, Error>{
        Future{
            try await self.loadModel(from: url)
        }
    }
}

extension Future where Failure == Error{
    convenience init(operation: @escaping() async throws -> Output) {
        self.init { promise in
            Task{
                do{
                    let output = try await operation()
                    promise(.success(output))
                }catch{
                    promise(.failure(error))
                }
            }
        }
    }
}
