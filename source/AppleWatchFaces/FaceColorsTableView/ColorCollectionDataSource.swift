//
//  ColorColectionDataSource.swift
//  AppleWatchFaces
//
//  Created by Michael Hill on 5/17/19.
//  Copyright © 2019 Michael Hill. All rights reserved.
//

import UIKit

class ColorCollectionDataSource: NSObject, UICollectionViewDataSource {
    
    var faceColors: [String] = []
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return faceColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "settingsColorCell", for: indexPath) as! ColorSettingCollectionViewCell
        
        //buffer
        let buffer:CGFloat = CGFloat(Int(cell.frame.size.width / 10))
        let corner:CGFloat = CGFloat(Int(buffer / 2))
        cell.circleView.frame = CGRect.init(x: corner, y: corner, width: cell.frame.size.width-buffer, height: cell.frame.size.height-buffer)
                
        cell.circleView.layer.cornerRadius = cell.circleView.frame.height / 2
        cell.circleView.backgroundColor = UIColor.init(hexString: faceColors[indexPath.row] )
       
        return cell
    }
    
}
