//
//  DownloadHelper.swift
//  AutodocTest
//
//  Created by Даниил Мурыгин on 18.05.2024.
//

import Foundation

final class DownloadHelper: NSObject{
    static private(set) var shared = DownloadHelper()
    private override init() {}
    
    func download(_ url: URL?) async throws -> Data? {
        guard let url else { return nil }
        
        // Check if data is cached already
        if let cachedResponse = URLCache.shared.cachedResponse(for: .init(url: url)) {
            return cachedResponse.data
        } else {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            // Save returned data into the cache
            URLCache.shared.storeCachedResponse(.init(response: response, data: data), for: .init(url: url))
            return data
        }
    }
}
