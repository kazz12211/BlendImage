//
//  ImageBlender.swift
//  ImageCompose
//
//  Created by Kazuo Tsubaki on 2018/08/16.
//  Copyright © 2018年 Kazuo Tsubaki. All rights reserved.
//

import UIKit

class ImageBlender: NSObject {
    
    var blendMode: CGBlendMode = .normal
    
    func blendImages(baseImage: UIImage, overImage: UIImage, completionHandler blendedImage: (UIImage?) -> (Swift.Void)) {
        let size = CGSize(width: baseImage.size.width, height: baseImage.size.height)
        let rect = CGRect(x: 0, y: 0, width: baseImage.size.width, height: baseImage.size.height)
        let image: UIImage = baseImage.copy() as! UIImage
        UIGraphicsBeginImageContextWithOptions(size, true, baseImage.scale)
        image.draw(in: rect, blendMode: .normal, alpha: 1.0)
        overImage.draw(in: rect, blendMode: blendMode, alpha: 1.0)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        blendedImage(newImage)
    }
}
