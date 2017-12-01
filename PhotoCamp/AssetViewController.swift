//
//  AssetViewController.swift
//  PhotoCamp
//
//  Created by Torris on 11/30/17.
//  Copyright © 2017 Torris. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class AssetViewController: UIViewController {
    
    var asset: PHAsset!
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    // MARK: UIViewController / Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Make sure the view layout happens before requesting an image sized to fit the view.
        view.layoutIfNeeded()
        updateContent()
    }

    // MARK: Image display
    
    var targetSize: CGSize {
        let scale = UIScreen.main.scale
        return CGSize(width: imageView.bounds.width * scale,
                      height: imageView.bounds.height * scale)
    }
    
    func updateContent() {
        // Prepare the options to pass when fetching the (photo, or video preview) image.
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.progressHandler = { progress, _, _, _ in
            
            DispatchQueue.main.sync {
                self.progressView.progress = Float(progress)
            }
        }
        
        self.progressView.isHidden = false
        PHImageManager.default().requestImage(for: asset,
                                              targetSize: targetSize,
                                              contentMode: .aspectFit,
                                              options: options,
                                              resultHandler: { image, _ in
                                                // Hide the progress view now the request has completed.
                                                self.progressView.isHidden = true
                                                
                                                // If successful, show the image view and display the image.
                                                guard let image = image else { return }
                                                
                                                // Now that we have the image, show it.
                                                self.imageView.isHidden = false
                                                self.imageView.image = image
        })
    }
    
}

