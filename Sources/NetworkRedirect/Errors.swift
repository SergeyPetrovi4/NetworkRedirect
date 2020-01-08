//
//  Errors.swift
//  HTTPRedirect
//
//  Created by Sergey Krasiuk on 07/01/2020.
//  Copyright © 2020 Sergey Krasiuk. All rights reserved.
//

import Foundation

protocol CodeError: LocalizedError {
    var code: Int { get }
    var errorDescription: String? { get }
}

struct ServiceError: CodeError {
    
    var code: Int
    var errorDescription: String?
    
    init(with code: Int, description: String?) {
        self.code = code
        self.errorDescription = description
    }
}

struct RedirectError {
    static let tooManyRedirects = ServiceError(with: -1007, description: "Too many HTTP redirects")
    static let parsingJSON = ServiceError(with: -1, description: "Parsing JSON fail")
}
