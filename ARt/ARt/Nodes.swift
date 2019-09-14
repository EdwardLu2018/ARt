//
//  Nodes.swift
//  ARt
//
//  Created by Edward on 9/14/19.
//  Copyright © 2019 Edward. All rights reserved.
//

import Foundation
import SceneKit

final class Nodes {
    static let WIDTH: CGFloat = 0.05
    static let HEIGHT: CGFloat = 10
    static let LENGTH: CGFloat = 8
    
    class func wall(width: CGFloat  = Nodes.WIDTH,
                    height: CGFloat = Nodes.HEIGHT,
                    length: CGFloat = Nodes.LENGTH) -> SCNNode {
        let node = SCNNode()
        
        let wall = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
        wall.firstMaterial?.diffuse.contents = UIColor.gray
        wall.firstMaterial?.writesToDepthBuffer = true
        wall.firstMaterial?.readsFromDepthBuffer = true
//        if let img = image {
//            wall.firstMaterial?.diffuse.contents = img
//        }
        
        let wallNode = SCNNode(geometry: wall)
        wallNode.renderingOrder = 200
        node.addChildNode(wallNode)
        
        let mask = SCNBox(width: width, height: height, length: length, chamferRadius: 0)
        mask.firstMaterial?.diffuse.contents = UIColor.white
        mask.firstMaterial?.transparency = 0.000001
        mask.firstMaterial?.writesToDepthBuffer = true
        let maskNode = SCNNode(geometry: mask)
        maskNode.renderingOrder = 100
        maskNode.position = SCNVector3.init(width, 0, 0)
        node.addChildNode(maskNode)
        
        return node
    }
    
    class func addImage(width: CGFloat = Nodes.WIDTH*2,
                        height: CGFloat = Nodes.HEIGHT/3,
                        length: CGFloat = Nodes.LENGTH/5,
                        parent: SCNNode,
                        z: Float, y: Float,
                        image: UIImage) -> SCNBox {
        let imageGeo = SCNBox(width: width, height: height, length: length, chamferRadius: Nodes.WIDTH*5)
        imageGeo.firstMaterial?.diffuse.contents = UIColor.black
        imageGeo.firstMaterial?.writesToDepthBuffer = true
        imageGeo.firstMaterial?.readsFromDepthBuffer = true
        imageGeo.firstMaterial?.diffuse.contents = image
        
        let imageNode = SCNNode(geometry: imageGeo)
        imageNode.renderingOrder = 300
        imageNode.position.x = -Float(Nodes.WIDTH*2)
        imageNode.position.y = y
        imageNode.position.z = z
        
        parent.addChildNode(imageNode)
        
        return imageGeo
    }
    
    class func changeImage(_ box: SCNBox, _ image: UIImage) {
        box.firstMaterial?.diffuse.contents = image
    }
}
