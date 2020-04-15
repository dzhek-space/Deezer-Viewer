//
//  ViewModelType.swift
//  Deezer Playlists
//
//  Created by Dzhek on 12.03.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation

protocol ViewModelType {

    associatedtype Input
    associatedtype Output
    
    var input: Input { get }
    var output: Output { get }
    
}

extension ViewModelType {
    
    func convertSetToViewModel<S, VM: InitiatebleFrom>(_ setOfItems: [S]) -> [VM] where VM.T == S {
       var viewModel = [VM]()
       setOfItems.forEach { viewModel.append( VM.init(from: $0) ) }
       return viewModel
    }
    
}
