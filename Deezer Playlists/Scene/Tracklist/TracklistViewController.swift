//
//  TracklistViewController.swift
//  Deezer Playlists
//
//  Created by Dzhek on 21.01.2020.
//  Copyright © 2019 Dzhek. All rights reserved.
//

import UIKit
import RxSwift

fileprivate typealias DataSource = UICollectionViewDiffableDataSource<PlaylistViewModel, TrackViewModel>
fileprivate typealias Snapshot = NSDiffableDataSourceSnapshot<PlaylistViewModel, TrackViewModel>

final class TracklistViewController: UIViewController {
    
    var viewModel: TracklistViewModel!
    
    private var dataSource: DataSource! = nil
    private var currentSnapshot: Snapshot! = nil
    private var collectionView: UICollectionView! = nil
    private var activityView: ActivityView! = nil
    private var closeChevron: UIImageView! = nil
    
    private let needLoadSubjectModel = PublishSubject<Void>()
    private let needLoadMoreSubjectModel = PublishSubject<Void>()
    private let disposeBag = DisposeBag()
    
    private var playlistViewModel: PlaylistViewModel! = nil
    private var isLoading: Bool = false
    private var isBindedModel: Bool = false
    private var isNextPageExist: Bool = false
    
    private let inset: CGFloat = Constants.Size.inset
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        configureDataSource()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !isBindedModel { bindViewModel() }
    }
    
    private func bindViewModel() {
        // Input
        needLoadSubjectModel
            .subscribe(viewModel.input.needLoad)
            .disposed(by: self.disposeBag)
        
        needLoadMoreSubjectModel
            .subscribe(viewModel.input.needMoreDownload)
            .disposed(by: self.disposeBag)
        
        // Output
        viewModel.output.playlist
            .drive(
                onNext: { [weak self] in
                    self?.playlistViewModel = $0
                    self?.takeSnapshot(of: []) {
                        self?.loadTraks()
                    }
            })
            .disposed(by: self.disposeBag)
        
        viewModel.output.tracklistState
            .drive(
                onNext: { [weak self] in
                    self?.takeSnapshot(of: $0.0) {
                        self?.finishUpdate()
                    }
                    self?.isNextPageExist = $0.1
                })
            .disposed(by: self.disposeBag)
        
        isBindedModel = true
    }
    
    private func loadTraks() {
        if isLoading { return }
        isLoading = true
        activityView = ActivityView()
        self.view.addSubview(activityView)
        let bounds = self.view.bounds
        activityView.show(within: bounds, as: .bottom) { [weak self] in
            self?.needLoadSubjectModel.onNext(())
        }
    }
    
    private func loadMoreTraks() {
        if isLoading { return }
        isLoading = true
        activityView = ActivityView()
        self.view.addSubview(activityView)
        let bounds = self.view.bounds
        activityView.show(within: bounds, as: .bottom) { [weak self] in
            self?.needLoadMoreSubjectModel.onNext(())
        }
    }
    
    private func finishUpdate() {
        if !isLoading { return }
        isLoading = false
        if activityView == nil { return }
        activityView.hide { [weak self] in
            self?.activityView = nil
        }
    }
    
}

// MARK: - Configure views

extension TracklistViewController {
    
    private func configureViews() {
        self.view.backgroundColor = Constants.Color.secondary.ui
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: inset * 1.5, weight: .light, scale: .large)
        let chevron = UIImage(systemName: "chevron.compact.down", withConfiguration: chevronConfig)!
            .withTintColor(Constants.Color.gray.ui, renderingMode: .alwaysOriginal)
        closeChevron = UIImageView(image: chevron)
        self.view.addSubview(closeChevron)
        collectionView =  UICollectionView(frame: .zero, collectionViewLayout: collectionViewLayout)
        self.view.addSubview(collectionView)
        confugureCollectionView()
        configureConstraint()
    }
    
    private func configureConstraint() {
        closeChevron.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        let safeLayout = self.view.safeAreaLayoutGuide
        NSLayoutConstraint.activate([
            closeChevron.topAnchor.constraint(equalTo: safeLayout.topAnchor),
            closeChevron.centerXAnchor.constraint(equalTo: safeLayout.centerXAnchor),
            
            collectionView.topAnchor.constraint(equalTo: closeChevron.bottomAnchor),
            collectionView.trailingAnchor.constraint(equalTo: safeLayout.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: safeLayout.leadingAnchor),
        ])
    }

}

// MARK: - CollectionViewLayout

extension TracklistViewController {
    
    private var collectionViewLayout: UICollectionViewLayout {
        let layout = TracklistCollectionViewLayout(section: self.section)
        return layout
    }
    
    private var section: NSCollectionLayoutSection {
        let section = NSCollectionLayoutSection(group: self.group)
        section.boundarySupplementaryItems = [self.sectionHeader]
        section.contentInsets = NSDirectionalEdgeInsets(top: inset,
                                                        leading: inset,
                                                        bottom: inset,
                                                        trailing: inset)
        section.interGroupSpacing = inset / 2
        return section
    }
    
    private var group: NSCollectionLayoutGroup {
        let cellHeight: CGFloat = {
            let heightFirstLine = Constants.Font.headline(size: Constants.Size.inset).lineHeight
            let heightSecondLine = Constants.Font.subheadline(size: (Constants.Size.inset * 0.9).rounded()).lineHeight
            let heightLineSpacing = inset * 0.5
            let heightLabelLines = heightFirstLine + heightSecondLine + heightLineSpacing
            return heightLabelLines + inset * 2
        }()
        let cellWidth: CGFloat = { Constants.Size.screenWidth - inset * 3 }()
        
        let cellLayoutSize = NSCollectionLayoutSize(widthDimension: .absolute(cellWidth),
                                                    heightDimension: .absolute(cellHeight))
        let cellItem = NSCollectionLayoutItem(layoutSize: cellLayoutSize)
        cellItem.edgeSpacing = NSCollectionLayoutEdgeSpacing(leading: .fixed(inset / 2),
                                                             top: nil,
                                                             trailing: .fixed(inset / 2),
                                                             bottom: nil)
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: cellLayoutSize,
                                                       subitem: cellItem,
                                                       count: 1)
        return group
    }
    
    private var headerKind: String { UICollectionView.elementKindSectionHeader }
    
    private var sectionHeader: NSCollectionLayoutBoundarySupplementaryItem {
        let headerHeight: CGFloat = {
            let heightFirstLine = Constants.Font.headline(size: (Constants.Size.inset * 1.33).rounded()).lineHeight
            let heightSecondAndThirdLine = Constants.Font.subheadline(size: Constants.Size.inset).lineHeight * 2
            let heightLineSpacing = inset
            let heightLabelsStackView = heightFirstLine + heightSecondAndThirdLine + heightLineSpacing
            return Constants.Size.screenWidth + heightLabelsStackView
        }()
        
        let headerLayoutSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                                      heightDimension: .estimated(headerHeight))
        let sectionHeader = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: headerLayoutSize,
                                                                        elementKind: headerKind,
                                                                        alignment: .top)
        sectionHeader.pinToVisibleBounds = true
        return sectionHeader
    }
    
    private func confugureCollectionView() {
        self.collectionView.delegate = self
        self.collectionView.register(TrackViewCell.self,
                                     forCellWithReuseIdentifier: TrackViewCell.identifier)
        self.collectionView.register(TracklistHeaderView.self,
                                     forSupplementaryViewOfKind: headerKind,
                                     withReuseIdentifier: TracklistHeaderView.identifier)
        self.collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.backgroundColor = .clear
    }
    
}

// MARK: - DataSource

extension TracklistViewController {
    
    private func takeSnapshot(of traks: [TrackViewModel], completion: @escaping () -> Void) {
        guard let playlist = self.playlistViewModel
            else { return }
        currentSnapshot = Snapshot()
        currentSnapshot.appendSections([playlist])
        currentSnapshot.appendItems(traks, toSection: playlist)
        dataSource.apply(currentSnapshot, animatingDifferences: false) {
            completion()
        }
    }

    private func configureDataSource() {
        dataSource = DataSource( collectionView: collectionView, cellProvider: { (collectionView, indexPath, track) -> UICollectionViewCell? in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackViewCell.identifier, for: indexPath) as? TrackViewCell
                else { fatalError("Cannot create new cell") }
            
            cell.applyModel(track)
            return cell
        })
        
        dataSource.supplementaryViewProvider = { [weak self] (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            guard let `self` = self, let snapshot = self.currentSnapshot
                else { return nil }
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TracklistHeaderView.identifier, for: indexPath) as? TracklistHeaderView
                else { fatalError("Cannot create header") }
            
            header.applyModel(snapshot.sectionIdentifiers[indexPath.section])
            return header
        }
    }
    
}

// MARK: - CollectionView Delegate

extension TracklistViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let hiddenBottomPart = scrollView.contentSize.height - (scrollView.contentOffset.y + scrollView.bounds.height)
        let isReachedLoadingArea = hiddenBottomPart < scrollView.bounds.height / 2
        if isReachedLoadingArea && isNextPageExist {
            loadMoreTraks()
        }
    }
    
}
