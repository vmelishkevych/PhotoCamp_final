//
//  GridViewCell.swift
//  PhotoCamp
//
//  Created by Torris on 11/30/17.
//  Copyright © 2017 Torris. All rights reserved.
//

import UIKit
import Photos
import PhotosUI

class GridViewCell: UICollectionViewCell {
    
    
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sizeLabel: UILabel!
    @IBOutlet weak var hashLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    
    var representedAssetIdentifier: String!
    
    var asset: PHAsset! {
        
        didSet {
            
            if asset == nil {
                
                nameLabel.text = nil
                sizeLabel.text = nil
                hashLabel.text = nil
                
            } else {
                
                // set file name
                
                let resources = PHAssetResource.assetResources(for: asset)
                let resourse = resources.last
                let fileName = resourse?.originalFilename
                
                self.nameLabel.text = fileName ?? "no data"
                
                // fetch asset data
                
                PHImageManager.default().requestImageData(for: asset,
                                                          options: nil) { (data, _, _, _) in
                                                            
                                                            if let data = data {
                                                                
                                                                // set file size
                                                                
                                                                let sizeOfData = data.count
                                                                let fileSize = self.fileSizeFromValue(sizeOfData)
                                                                self.sizeLabel.text = fileSize
                                                                
                                                                // set hash value
                                                                
                                                                DispatchQueue.global(qos: .utility).async {
                                                                    
                                                                    let md5Data = self.md5(data: data)
                                                                    
                                                                    let md5DataHexString = self.hexStringFromData(data: md5Data)
                                                                    
                                                                    DispatchQueue.main.async {
                                                                        self.hashLabel.text = md5DataHexString
                                                                    }
                                                                }
                                                                
                                                            }
                                                            
                }
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.asset = nil
        imageView.image = UIImage(named: "no_image")
        imageView.isHidden = true
        
    }

    // help methods
    
    func md5(data: Data) -> Data {
        
        var digestData = Data.init(count: Int(CC_MD5_DIGEST_LENGTH))
        
        _ = digestData.withUnsafeMutableBytes({ (digestBytes) in
            
            data.withUnsafeBytes({ (dataBytes) in
                
                CC_MD5(dataBytes, CC_LONG(data.count), digestBytes)
            })
        })
        
        return digestData
    }
    
    
    
    func hexStringFromData(data: Data) -> String {
        
        let bytesHexStringArray = data.map({ (byte) -> String in
            
            return String(format: "%02x", byte)
        })
        
        return bytesHexStringArray.joined()
    }

    func fileSizeFromValue(_ value: Int) -> String {
        
        let units = ["B", "KB", "MB", "GB", "TB"]
        let unitCount = 5
        
        var index = 0
        var fileSize =  Double(value)
        
        while (fileSize > 1024 && index < unitCount) {
            
            fileSize /= 1024
            index += 1
        }
        
        return String(format: "%.2f", fileSize) + units[index]
    }
    
}

