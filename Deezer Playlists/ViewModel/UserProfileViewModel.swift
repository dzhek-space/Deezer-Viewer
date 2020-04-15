//
//  UserProfileViewModel.swift
//  Deezer Playlists
//
//  Created by Dzhek on 02.03.2020.
//  Copyright © 2020 Dzhek. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

// Relevant id
var succes = [753546365, 643790541, 1842398, 1701245, 902801015, 938973527, 152734253, 686576633, 10596443, 9456080, 8396007, 4644777, 1661469, 270436, 423807, 1323294848, 918594, 2957134, 1614208646, 2349829, 467995233]

fileprivate var randomUserId: Observable<Int> {
    return Observable.deferred {
        
        let randId = succes.isEmpty ? Int.random(in: 5...2352258) : succes.removeLast()
//        print("        ----------- •-•-•-•-•-•- {  \(id)  } •-•-•-•-•-•- -----------        ")
        return Observable.just(randId)
    }
}

final class UserProfileViewModel: ViewModelType {
    
    typealias ResultViewModel = (user: UserViewModel, playlists: [PlaylistViewModel], isNextPageExist: Bool)
    
    let input: Input
    let output: Output
    
    private let loaderSubject = PublishSubject<Void>()
    private let moreDownloaderSubject = PublishSubject<Void>()
    private let loaderImagesSubject = PublishSubject<[PlaylistViewModel]>()
    private var nextUrlSubject = ReplaySubject<String?>.create(bufferSize: 1)
    private var userModelSubject = ReplaySubject<UserViewModel>.create(bufferSize: 1)
    private var playlistsModel = ReplaySubject<[PlaylistViewModel]>.create(bufferSize: 1)
    private var modelSubject = PublishRelay<ResultViewModel>()
    private var imageUpdaterSubject = PublishRelay<PlaylistViewModel>()
    
    private let serialDefaultQueue = SerialDispatchQueueScheduler(qos: .default)
    private let concurrentDefaultQueue = ConcurrentDispatchQueueScheduler(qos: .default)
    private let concurrentUserInitiatedQueue = SerialDispatchQueueScheduler(qos: .userInitiated)
    private let synchronizationLock = NSRecursiveLock()

    private let disposeBag = DisposeBag()

    init() {
        input = Input(needSelectUser: loaderSubject.asObserver(),
                      needMoreDownload: moreDownloaderSubject.asObserver(),
                      needLoadImages: loaderImagesSubject.asObserver())
        
        let model = modelSubject
            .asDriver(onErrorJustReturn: (user: MockViewModel().user,
                                          playlists: [MockViewModel().playlist],
                                          isNextPageExist: false ))
        
        self.output = Output(model: model, imageUpdater: imageUpdaterSubject)
        
        selectUser()
        loadNextPartPlaylists()
        toLoadImages()
    
    }
    
    private func selectUser() {
        let selectedUser = randomUserId
            .observeOn(serialDefaultQueue)
            .map { API(userId: $0).userResource.fetchJson().asObservable() }
            .concat()
            .retry()
            .do(onNext: {
                ImageCache.publicCache.clearCache()
                ImageCache.publicCache.cacheImageData(for: $0.avatarUrl as NSString)
                    .subscribe()
                    .disposed(by: ImageCache.publicCache.disposeBag)
                })
            .share()

        let setOfPlaylist = selectedUser
            .map { API(userId: $0.id).playlistsResource.fetchJson().asObservable() }
            .concat()
            .share()

        loaderSubject
            .observeOn(concurrentDefaultQueue)
            .map { Observable.combineLatest(selectedUser, setOfPlaylist) }
            .concat()
            .map { (user, set) -> ResultViewModel in
                let userModel = UserViewModel(user: user, totalPlaylists: set.total)
                let playlistsModel = self.convertSetToViewModel(set.setOfItems) as [PlaylistViewModel]
                self.userModelSubject.asObserver().onNext(userModel)
                self.nextUrlSubject.asObserver().onNext(set.next)
                self.playlistsModel.asObserver().onNext(playlistsModel)
                return (user: userModel,
                        playlists: playlistsModel,
                        isNextPageExist: set.next != nil)
            }
            .bind(to: modelSubject)
            .disposed(by: disposeBag)
    }
    
    private func loadNextPartPlaylists() {
        let updatedModelSubject = self.nextUrlSubject
            .observeOn(concurrentDefaultQueue)
            .takeWhile { $0 != nil }
            .withLatestFrom(userModelSubject) {
                API(userId: $1.id, query: $0).playlistsResource.fetchJson().asObservable()
            }
            .concat()
            .do(onNext: { self.nextUrlSubject.asObserver().onNext($0.next) })
            .map { self.convertSetToViewModel($0.setOfItems) as [PlaylistViewModel] }
            .withLatestFrom(playlistsModel) { $1 + $0 }
            .do(onNext: { self.playlistsModel.onNext($0) })
            .withLatestFrom(userModelSubject) { ($1,$0) }
            .withLatestFrom(nextUrlSubject) { (user: $0.0,
                                             playlists: $0.1,
                                             isNextPageExist: $1 != nil) }
            .take(1)

        moreDownloaderSubject
            .map { updatedModelSubject }
            .concat()
            .bind(to: modelSubject)
            .disposed(by: disposeBag)
    }
    
    private func toLoadImages() {
        loaderImagesSubject
            .subscribe(
                onNext: {
                    $0.forEach { self.loadCoverPlaylist($0) }
                })
            .disposed(by: disposeBag)
    }
    
    private func loadCoverPlaylist(_ playlist: PlaylistViewModel) {
        let currentPlaylist = playlist
        let keyUrl = currentPlaylist.coverUrl as NSString
        if ImageCache.publicCache.cachedImage(key: keyUrl) == nil {
            ImageCache.publicCache.cacheImageData(for: keyUrl)
                .subscribe(
                    onSuccess: { isCached in
                        if isCached {
                            self.synchronizationLock.lock()
                            self.imageUpdaterSubject.accept(currentPlaylist)
                            self.synchronizationLock.unlock()
                        }
                })
                .disposed(by: ImageCache.publicCache.disposeBag)
        }
    }

}


// MARK: - Input / Output Struct

extension UserProfileViewModel {
    
    struct Input {
        let needSelectUser: AnyObserver<Void>
        let needMoreDownload: AnyObserver<Void>
        let needLoadImages: AnyObserver<[PlaylistViewModel]>
    }
    
    struct Output {
        let model: Driver<ResultViewModel>
        let imageUpdater: PublishRelay<PlaylistViewModel>
    }
    
}


// MARK: - Dependencies

extension UserProfileViewModel {
    
    struct API {
        let userResource: Resource<User>
        let playlistsResource: Resource<TemplateSet<Playlist>>
        
        init(userId: Int, query: String? = nil) {
            self.userResource = Resource<User>(endpoint: .user(userId: userId))
            self.playlistsResource = Resource<TemplateSet<Playlist>>(endpoint: .playlists(userId: userId, query: query))
        }
    }
    
}
