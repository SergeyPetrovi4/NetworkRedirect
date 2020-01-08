//
//  NetworkRedirect.swift
//  HTTPRedirect
//
//  Created by Sergey Krasiuk on 06/01/2020.
//  Copyright © 2020 Sergey Krasiuk. All rights reserved.
//

import Foundation

public typealias CompletionHandler = (Result<String, Error>) -> ()

public class NetworkRedirect: NSObject {
        
    public static let shared = NetworkRedirect()
    private override init() {
        super.init()
        
        self.session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    
    var session: URLSession?
    var completion: CompletionHandler?
    
    /// Set maximum number count of redirections (default 3)
    public var maxNumberOfRedirections: Int = 3
    private var numberOfCurrentRedirection: Int = 0
    
    /// Request method with redirection support
    public func request(withURL url: URL, completion: CompletionHandler?) {
        self.completion = completion
        
        let taskSession = self.session?.dataTask(with: url) { (data, response, error) in
            
            guard let responseData = data,
                let response = response as? HTTPURLResponse,
                (200 ..< 300) ~= response.statusCode,
                error == nil else {
                    
                    completion?(.failure(error!))
                return
            }
            
            print(url.absoluteString, "\n\(response.statusCode) OK")
            
            // In our case we will send only value of dictionary
            do {
                if let json = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                    if let value = json["hello"] as? String {
                        completion?(.success(value))
                    }
                }
            } catch _ {
                completion?(.failure(RedirectError.parsingJSON))
            }
        }
        
        taskSession?.resume()
    }
}

extension NetworkRedirect: URLSessionTaskDelegate {
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           willPerformHTTPRedirection response: HTTPURLResponse,
                           newRequest request: URLRequest,
                           completionHandler: @escaping (URLRequest?) -> Void) {
        
        
        if response.statusCode == 301, let url = request.url, self.numberOfCurrentRedirection < self.maxNumberOfRedirections {
            
            self.numberOfCurrentRedirection += 1
            print(url.absoluteString, "\n\(response.statusCode) Moved permanently")
            self.request(withURL: url, completion: self.completion)
            return
            
        } else {            
            self.completion?(.failure(RedirectError.tooManyRedirects))
        }
        
        return
    }
}
