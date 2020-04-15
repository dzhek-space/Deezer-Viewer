//
//  UserProfileViewController.swift
//  Deezer Playlists
//
//  Created by Dzhek on 22.01.2020.
//  Copyright © 2019 Dzhek. All rights reserved.
//

import UIKit
import RxSwift

fileprivate typealias DataSource = UICollectionViewDiffableDataSource<UserViewModel, PlaylistViewModel>
fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<UserViewModel, PlaylistViewModel>

final class UserProfileViewController: UIViewController {

    private var viewModel: UserProfileViewModel! = nil
    private var dataSource: DataSource! = nil
    private var collectionView: UICollectionView! = nil
    private var activityView: ActivityView! = nil
    
    private let refreshUserProfile = PublishSubject<Void>()
    private let refreshSetOfPlaylists = PublishSubject<Void>()
    private let refreshImages = PublishSubject<[PlaylistViewModel]>()
    private let disposeBag = DisposeBag()
    
    private var currentUser: UserViewModel!
    private var isLoading: Bool = false
    private var isNextPageExist: Bool = false
    private var needChangeUser: Bool = false
    
    private let inset: CGFloat = Constants.Size.inset
    private let indentToRefresh: CGFloat = Constants.Size.inset * 7
    private let applyingUIQueue = DispatchQueue(label: "com.deezer.random_user")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewModel = UserProfileViewModel()
        bindViewModel()
        configureViews()
        configureDataSource()
        startUserSelection()
    }
        
    private func bindViewModel() {
        // Input
        refreshUserProfile
            .subscribe(viewModel.input.needSelectUser)
            .disposed(by: disposeBag)
        
        refreshSetOfPlaylists
            .subscribe(viewModel.input.needMoreDownload)
            .disposed(by: disposeBag)
        
        refreshImages
            .subscribe(viewModel.input.needLoadImages)
            .disposed(by: disposeBag)
 
        // Output
        viewModel.output.model
            .drive(
                onNext: { [weak self] model in
                    self?.currentUser = model.user
                    self?.takeSnapshot(model.playlists)
                    self?.isNextPageExist = model.isNextPageExist
                })
            .disposed(by: disposeBag)
        
        viewModel.output.imageUpdater
            .bind(onNext: { self.refreshImage(for: $0) })
            .disposed(by: disposeBag)
    }
    
    private func startUserSelection() {
        if isLoading { return }
        isLoading = true
        needChangeUser = false
        activityView = ActivityView()
        self.view.addSubview(activityView)
        let bounds = self.view.bounds
        activityView.show(within: bounds, as: .fullscreen) { [weak self] in
            self?.refreshUserProfile.onNext(())
        }
    }
    
    private func loadMorePlaylists() {
        if isLoading { return }
        isLoading = true
        activityView = ActivityView()
        self.view.addSubview(activityView)
        let bounds = self.view.bounds
        activityView.show(within: bounds, as: .bottom) { [weak self] in
            self?.refreshSetOfPlaylists.onNext(())
        }
    }
    
    private func finishUpdate() {
        if !isLoading { return }
        isLoading = false
        if activityView == nil { return }
        activityView.hide { [weak self] in
            self?.activityView = nil
        }
        if collectionView.alpha < 1 {
            finalAnimation.startAnimation()
        }
    }
    
}

// MARK: - Configure Views

extension UserProfileViewController {
    
    private func configureViews() {
        self.view.backgroundColor = Constants.Color.secondary.ui
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.view.addSubview(collectionView)
        confugureCollectionView()
        configureConstraint()
    }
    
    private func configureConstraint() {
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let safeLayout = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: safeLayout.topAnchor, constant: inset / 2),
            collectionView.trailingAnchor.constraint(equalTo: safeLayout.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeLayout.leadingAnchor),
        ])
    }
    
}

// MARK: - CollectionViewLayout

extension UserProfileViewController {
    
    private var collectionViewLayout: UICollectionViewLayout {
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    private var section: NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(top: inset,
                                                        leading: inset,
                                                        bottom: inset,
                                                        trailing: inset)
        section.interGroupSpacing = inset / 2
        return section
    }
    
    private var group: NSCollectionLayoutGroup {
        let estimatedHeight = CGFloat(156)
        let groupCellLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                         heightDimension: .estimated(estimatedHeight))
        let cellItem = NSCollectionLayoutItem(layoutSize: groupCellLayoutSize)
        cellItem.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(inset / 2),
                                                             top: .fixed(inset / 6),
                                                             trailing: .fixed(inset / 2),
                                                             bottom: .fixed(inset / 6))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupCellLayoutSize,
                                                       subitem: cellItem,
                                                       count: 3)
        group.interItemSpacing = .flexible(inset * 1.5)
        return group
    }
    
    private var sectionHeader: NSCollectionLayoutBoundarySupplementaryItem {
        let headerLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .absolute(inset * 7))
        let headerKind = UICollectionView.elementKindSectionHeader
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerLayoutSize,
                                                                        elementKind: headerKind,
                                                                        alignment: .top)
        sectionHeader.pinToVisibleBounds = true
        return sectionHeader
    }
    
    private func confugureCollectionView() {
        collectionView.delegate = self
        collectionView.register(PlaylistViewCell.self,
                                     forCellWithReuseIdentifier: PlaylistViewCell.identifier)
        collectionView.register(UserHeaderView.self,
                                     forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                     withReuseIdentifier: UserHeaderView.identifier)
        
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.alwaysBounceVertical = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        collectionView.alpha = 0
    }
    
}

// MARK: - DataSource

extension UserProfileViewController {
    
    private func takeSnapshot(_ playlists: [PlaylistViewModel]) {
        guard let user = self.currentUser
            else { return }
        var snapshot = Snapshot()
        applyingUIQueue.async { 
            snapshot.appendSections([user])
            snapshot.appendItems(playlists, toSection: user)
            self.dataSource.apply(snapshot, animatingDifferences: false) {
                self.refreshImages.onNext(playlists)
                DispatchQueue.main.async {
                    self.finishUpdate()
                }
            }
        }
    }
    
    private func refreshImage(for playlist: PlaylistViewModel) {
        var snapshot = dataSource.snapshot()
        applyingUIQueue.async {
            snapshot.reloadItems([playlist])
            self.dataSource.apply(snapshot, animatingDifferences: false)
        }
    }
    
    private func configureDataSource() {
        dataSource = DataSource( collectionView: collectionView, cellProvider: { (collectionView, indexPath, playlist) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PlaylistViewCell.identifier, for: indexPath) as? PlaylistViewCell
                else { fatalError("Cannot create new cell") }
            
            cell.applyModel(playlist)
            return cell
        })
        
        dataSource.supplementaryViewProvider = { [weak self]
            (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let `self` = self, let userModel = self.currentUser
                else { return nil }
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: UserHeaderView.identifier, for: indexPath) as? UserHeaderView
                else { fatalError("Cannot create header") }
            
            header.applyModel(userModel)
            return header
        }
    }
    
}

// MARK: - CollectionView Delegate

extension UserProfileViewController: UICollectionViewDelegate {

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let playlist = dataSource.itemIdentifier(for: indexPath)
            else { return }
        self.presentDetails(of: playlist)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {

        if scrollView.contentOffset.y < 0 {
            let offsetY = abs(scrollView.contentOffset.y)
            if offsetY <= indentToRefresh {
                scrollView.alpha = (indentToRefresh - offsetY) / indentToRefresh
            } else if needChangeUser && offsetY > indentToRefresh {
                scrollView.isScrollEnabled = false
                scrollView.setContentOffset(CGPoint(x: 0, y: -1 * indentToRefresh), animated: false)
                scrollView.alpha = 0
                startUserSelection()
            }
        }
        
        let hiddenBottomPart = scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.height)
        let isReachedLoadingArea = hiddenBottomPart < scrollView.bounds.height / 2
        if isReachedLoadingArea && isNextPageExist {
            loadMorePlaylists()
        }

    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        needChangeUser = -1...0 ~= Int(velocity.y) && targetContentOffset.pointee.y.isZero
    }
    
    private func presentDetails(of playlist: PlaylistViewModel) {
        let tracklistViewController = TracklistViewController()
        tracklistViewController.viewModel = TracklistViewModel(playlist: playlist)
        present(tracklistViewController, animated: true, completion: nil)
    }
    
}

// MARK: - Animation assistants

extension UserProfileViewController {
    
    private var finalAnimation: UIViewPropertyAnimator {
        let view = self.collectionView
        view?.contentOffset.y = -1 * indentToRefresh
        let animator = UIViewPropertyAnimator(duration: Constants.Timer.triple, curve: .easeOut) {
            view?.alpha = 1
            view?.contentOffset.y = 0
        }
        animator.addCompletion { _ in
          view?.isScrollEnabled = true
        }
        return animator
    }
    
}
