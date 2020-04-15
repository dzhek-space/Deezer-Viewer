//
//  TracklistCollectionViewLayout.swift
//  Deezer Playlists
//
//  Created by Dzhek on 21.01.2020.
//  Copyright © 2019 Dzhek. All rights reserved.
//

import UIKit

final class TracklistCollectionViewLayout: UICollectionViewCompositionalLayout {
    
    private let headerIndexPath = IndexPath(item: 0, section: 0)
    
    private lazy var fullHeaderHeight: CGFloat = {
        guard let headerAttributes = self.collectionView?.layoutAttributesForSupplementaryElement(ofKind: UICollectionView.elementKindSectionHeader, at: headerIndexPath)
            else { return 0 }
        return headerAttributes.frame.height
    }()
    
    private lazy var shortHeaderHeight: CGFloat = {
        let imageHeight = headerCoverView.frame.height
        let shortHeight = fullHeaderHeight - imageHeight
        return shortHeight
    }()
    
    private var headerCoverView: UIImageView {
        guard let headerView = self.collectionView?.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first as? TracklistHeaderView
            else { return UIImageView(frame: .zero) }
        return headerView.coverView
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let collectionView = self.collectionView
            else { return nil }
        let layoutAttributes = super.layoutAttributesForElements(in: rect)
        let needToChangeHeight = collectionView.contentOffset.y > 0
        let headerAttributes = self.layoutAttributesForSupplementaryView(
                                                        ofKind: UICollectionView.elementKindSectionHeader,
                                                        at: headerIndexPath)
        if needToChangeHeight, headerAttributes != nil {
            resizeHeaderFrame(headerAttributes!, to: collectionView.contentOffset.y)
        }
        
        return layoutAttributes
    }

    private func resizeHeaderFrame(_ headerAttributes: UICollectionViewLayoutAttributes, to offsetY: CGFloat) {
        let estimatedHeight = fullHeaderHeight - offsetY
        let newHeaderFrame = CGRect(x: headerAttributes.frame.minX,
                                    y: offsetY,
                                    width: headerAttributes.frame.width,
                                    height: max(estimatedHeight, shortHeaderHeight))
        headerAttributes.frame = newHeaderFrame
    }
    
}
