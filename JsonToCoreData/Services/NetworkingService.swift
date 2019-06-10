//
//  NetworkingService.swift
//  JsonToCoreData
//
//  Created by Googoo on 6/6/19.
//  Copyright © 2019 Derodian. All rights reserved.
//

import Foundation

enum Result <T>{
    case Success(T)
    case Error(String)
}

class NetworkingService {
    
    private init() {}
    static let instance = NetworkingService()
    
    func getDataWith(completion: @escaping (Result<[[String: AnyObject]]>) -> Void) {
        // Create URL to fetch data from
        guard let url = URL(string: fetchUrl) else {
            return completion(.Error("Invalid URL, cannot get data"))
        }
        
        // Fetch JSON using URLSession's DataTask
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                return completion(.Error(error!.localizedDescription))
            }
            guard let data = data else {
                return completion(.Error(error?.localizedDescription ?? "There are no new files to get"))
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: [.mutableContainers]) as? [String: AnyObject] {
                    guard let filesJsonArray = json["files"] as? [[String: AnyObject]] else {
                        return completion(.Error(error?.localizedDescription ?? "There are no new files to get"))
                    }
                    DispatchQueue.main.async {
                        completion(.Success(filesJsonArray))
                    }
                }
            } catch let error {
                completion(.Error(error.localizedDescription))
            }
        }.resume()
    }
}
