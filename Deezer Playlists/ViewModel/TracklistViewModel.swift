//
//  TracklistViewModel.swift
//  Deezer Playlists
//
//  Created by Dzhek on 12.03.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class TracklistViewModel: ViewModelType {

    let input: Input
    let output: Output
    
    private let playlistSubject = ReplaySubject<PlaylistViewModel>.create(bufferSize: 1)
    private let loaderSubject = PublishSubject<Void>()
    private let moreDownloaderSubject = PublishSubject<Void>()
    private let traksSubject = ReplaySubject<([TrackViewModel])>.create(bufferSize: 1)
    private let traksStateSubject = ReplaySubject<([TrackViewModel], Bool)>.create(bufferSize: 1)
    private let setSubject = PublishSubject<TemplateSet<Track>>()
    private let nextUrlSubject = ReplaySubject<String?>.create(bufferSize: 1)
    private let disposeBag = DisposeBag()
    
    init(playlist: PlaylistViewModel) {
        
        playlistSubject.onNext(playlist)
        
        input = Input(needLoad: loaderSubject.asObserver(),
                      needMoreDownload: moreDownloaderSubject.asObserver())
        
        let playlistModel = playlistSubject
            .asDriver(onErrorJustReturn: MockViewModel().playlist)
        
        let tracksModelState = traksSubject
            .withLatestFrom(nextUrlSubject) { ($0, $1 != nil) }
            .asDriver(onErrorJustReturn: ([MockViewModel().track], false))
            
        self.output = Output(playlist: playlistModel, tracklistState: tracksModelState)
        
        setSubject
            .do(onNext: { self.nextUrlSubject.onNext($0.next) })
            .map { self.convertSetToViewModel($0.setOfItems) as [TrackViewModel] }
            .scan([TrackViewModel]()) { $0 + $1 }
            .subscribe(traksSubject)
            .disposed(by: disposeBag)
        
        loaderSubject
            .map { self.playlistSubject }
            .concat()
            .subscribe(onNext: { self.getterSetSubject(playlistId: $0.id) })
            .disposed(by: disposeBag)
        
        let nextSetSubject = nextUrlSubject.take(1)
        
        moreDownloaderSubject
            .map { nextSetSubject }
            .concat()
            .subscribe(onNext: { self.getterSetSubject(nextLink: $0) })
            .disposed(by: disposeBag)
    }
    
    private func getterSetSubject(playlistId: Int? = nil, nextLink: String? = nil) {
        if playlistId != nil {
            let resourceSet = API(playlistId: playlistId!, query: nil).tracksResource
            resourceSet
                .fetchJson()
                .asObservable()
                .subscribe(
                    onNext: { self.setSubject.onNext($0) })
                .disposed(by: disposeBag)
            
        } else if nextLink != nil {
            guard let partsOfPath = URL(string: nextLink!)?.path.components(separatedBy: "/"),
                let idString = partsOfPath.first(where: { Int($0) != nil }),
                let id = Int(idString)
                else { return }
            let resourceSet = API(playlistId: id, query: nextLink).tracksResource
            resourceSet
                .fetchJson()
                .asObservable()
                .subscribe(
                    onNext: { self.setSubject.onNext($0) })
                .disposed(by: disposeBag)
        }
    }

}


// MARK: - Input / Output Struct

extension TracklistViewModel {
    
    struct Input {
        let needLoad: AnyObserver<Void>
        let needMoreDownload: AnyObserver<Void>
    }
    
    struct Output {
        let playlist: Driver<PlaylistViewModel>
        let tracklistState: Driver<([TrackViewModel], Bool)>
    }
    
}

// MARK: - Dependencies

extension TracklistViewModel {
    
    struct API {
        let tracksResource: Resource<TemplateSet<Track>>
        
        init(playlistId: Int, query: String? = nil) {
            self.tracksResource = Resource<TemplateSet<Track>>(endpoint: .tracks(playlistId: playlistId, query: query))
        }
    }
    
}
