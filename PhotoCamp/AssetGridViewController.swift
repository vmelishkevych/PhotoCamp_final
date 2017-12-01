//
//  AssetGridViewController.swift
//  PhotoCamp
//
//  Created by Torris on 11/30/17.
//  Copyright © 2017 Torris. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class AssetGridViewController: UICollectionViewController {
    
    var fetchResult: PHFetchResult<PHAsset>?
    
    fileprivate let imageManager = PHCachingImageManager()
    fileprivate var thumbnailSize: CGSize!

    
    // MARK: UIViewController / Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateItemSize()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateItemSize()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
  
    // help methods
    
    private func updateItemSize() {
        
        let viewWidth = view.bounds.size.width
        
        let desiredItemWidth: CGFloat = 100
        let columns: CGFloat = max(floor(viewWidth / desiredItemWidth), 3)
        let padding: CGFloat = 6
        let itemWidth = floor((viewWidth - (columns + 1) * padding) / columns)
        let itemSize = CGSize(width: itemWidth, height: itemWidth * 1.4)
        
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = itemSize
            layout.minimumInteritemSpacing = padding
            layout.minimumLineSpacing = padding
        }
        
        // Determine the size of the thumbnails to request from the PHCachingImageManager
        let scale = UIScreen.main.scale
        thumbnailSize = CGSize(width: itemSize.width * scale, height: itemSize.height * scale)
    }
    
    // MARK: UICollectionView
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchResult?.count ?? 0
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let asset = fetchResult!.object(at: indexPath.item)
        
        // Dequeue a GridViewCell.
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: GridViewCell.self),
                                                            for: indexPath) as? GridViewCell
            else { fatalError("unexpected cell in collection view") }
 
        cell.asset = asset
        
        // Request an image for the asset from the PHCachingImageManager.
        
        cell.representedAssetIdentifier = asset.localIdentifier
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            
            DispatchQueue.main.sync {
                cell.progressView.progress = Float(progress)
            }
        }
        
        cell.progressView.isHidden = false
        
        imageManager.requestImage(for: asset,
                                  targetSize: thumbnailSize,
                                  contentMode: .aspectFill,
                                  options: options,
                                  resultHandler: { image, _ in

                                    cell.progressView.isHidden = true
                                    cell.imageView.isHidden = false
                                    
                                    if cell.representedAssetIdentifier == asset.localIdentifier && image != nil {
                                        cell.imageView.image = image
                                    } else {
                                        cell.imageView.image = UIImage(named: "no_image")
                                    }
        })
        
        return cell
        
    }
    
    // MARK: actions
    
    // fetch assets from library
    @IBAction func fetchAssets(_ sender: UIBarButtonItem) {

        let allPhotosOptions = PHFetchOptions()
        allPhotosOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
        fetchResult = PHAsset.fetchAssets(with: .image, options: allPhotosOptions)
        
        if fetchResult != nil {
            
            navigationItem.rightBarButtonItem = nil
        }
        
        collectionView?.reloadData()
    }
    
    // segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let destination = segue.destination as? AssetViewController
            else { fatalError("unexpected view controller for segue") }
        guard let cell = sender as? UICollectionViewCell else { fatalError("unexpected sender") }
        
        if let indexPath = collectionView?.indexPath(for: cell) {
            destination.asset = fetchResult!.object(at: indexPath.item)
        }
        
    }

    
}
