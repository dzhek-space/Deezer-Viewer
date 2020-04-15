//
//  Error.swift
//  Deezer Playlists
//
//  Created by Dzhek on 10.03.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

struct AppError {
    
    enum Network: Error {
        case requestIsNil
        case requestTaskReturnedError
        case badResponse(description: String)
    }
    
    enum Decoding: Error {
        case decodingFailed
    }
    
    struct DeezerError: Decodable  {
        let type: String
        let message: String
        let code: Int
        
        enum CodingKeys: String, CodingKey {
            case error
        }
        
        enum ErrorKeys: String, CodingKey {
            case type, message, code
        }
        
        init(from decoder: Decoder) throws {
            
            let values = try decoder.container(keyedBy: CodingKeys.self)
            
            let errorValues = try values.nestedContainer(keyedBy: AppError.DeezerError.ErrorKeys.self, forKey: .error)
            type = try errorValues.decode(String.self, forKey: .type)
            message = try errorValues.decode(String.self, forKey: .message)
            code = try errorValues.decode(Int.self, forKey: .code)
        }
    }
    
}
