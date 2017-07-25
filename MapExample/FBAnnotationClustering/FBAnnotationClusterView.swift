//
//  FBAnnotationClusterView.swift
//  FBAnnotationClusteringSwift
//
//  Created by Robert Chen on 4/2/15.
//  Copyright (c) 2015 Robert Chen. All rights reserved.
//

import Foundation
import MapKit

class FBAnnotationClusterView : MKAnnotationView {
    
    var count = 0
    var fontSize:CGFloat = 12
    
    var imageName = "ClusterSmallUnselected"
    
//    var borderWidth:CGFloat = 3
    
    var countLabel:UILabel?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?){
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        let cluster:FBAnnotationCluster = annotation as! FBAnnotationCluster
        cluster.clusterView = self
        count = cluster.annotations.count
        
        // change the size of the cluster image based on number of stories
            switch count {
            case 0...5:
                fontSize = 12
                imageName = "ClusterSmallUnselected"
                //borderWidth = 3
                
            default:
                fontSize = 14
                imageName = "ClusterLargeUnselected"
                //borderWidth = 5
                
            }
            setupLabel()
            setTheCount(count)
        
        backgroundColor = UIColor.clear
        setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setupLabel(){
        countLabel = UILabel(frame: bounds)
        
        if let countLabel = countLabel {
            countLabel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            countLabel.textAlignment = .center
            countLabel.backgroundColor = UIColor.clear
            countLabel.textColor = UIColor(red: 24/255, green: 36/255, blue: 73/255, alpha: 0.6)
            countLabel.adjustsFontSizeToFitWidth = true
            countLabel.minimumScaleFactor = 2
            countLabel.numberOfLines = 1
            countLabel.font = UIFont (name: "pfdintextpro-medium", size: fontSize)
            countLabel.baselineAdjustment = .alignCenters
            addSubview(countLabel)
        }
        
    }
    
    func setTheCount(_ localCount:Int){
        count = localCount;
        countLabel?.text = "\(localCount)"
    }
    
    override func layoutSubviews() {
        
        // Images are faster than using drawRect:
        let imageAsset = UIImage(named: imageName)!
        
        countLabel?.frame = self.bounds
        image = imageAsset
        centerOffset = CGPoint.zero
        
        // adds a white border around the green circle
//        layer.borderColor = UIColor.whiteColor().CGColor
//        layer.borderWidth = borderWidth
//        layer.cornerRadius = self.bounds.size.width / 2
        
    }
    
    func changeViewForSelected(){
        
        countLabel?.textColor = UIColor.white
        switch count {
        case 0...5:
            imageName = "ClusterSmallSelected"
            
        default:
            imageName = "ClusterLargeSelected"
        }
        
        self.layoutSubviews()
    }
    
    func changeViewForUnselected(){
        countLabel?.textColor = UIColor(red: 24/255, green: 36/255, blue: 73/255, alpha: 0.6)
        switch count {
        case 0...5:
            imageName = "ClusterSmallUnselected"
            
            
        default:
            imageName = "ClusterLargeUnselected"
        }
        
        self.layoutSubviews()
    }
    
}
