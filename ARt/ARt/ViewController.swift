//
//  ViewController.swift
//  ARt
//
//  Created by Edward on 9/14/19.
//  Copyright © 2019 Edward. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

protocol ARController {
    var imgs: [SCNBox?] {get set}
    func changeImg(thing: SCNBox, img: UIImage)
    
    func changeName(name: String)
    func changeDescript(des: String)
    func changeArtist(art: String)
    func changeBirthplace(place: String)
}

class ViewController: UIViewController, ARSCNViewDelegate, ARController {
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var searchButton: UIButton!
    
    var actionLabel = UILabel()
    
    var img1wall1: SCNBox?
    var img1wall2: SCNBox?
    var img2wall1: SCNBox?
    var img2wall2: SCNBox?
    var img3wall1: SCNBox?
    var img3wall2: SCNBox?
    
    var imgs: [SCNBox?] = []
    
    enum InfoVCState {
        case expanded
        case collapsed
    }
    
    var infoViewController: InfoViewController!
    var visualEffectView: UIVisualEffectView!
    
    let infoVCHeight: CGFloat = 640
    let infoVCHandleArea: CGFloat = 40
    
    var infoVCVisible = false
    var canSwipeUp = true
    
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted: CGFloat = 0
    
    var panGestureRecognizer = UIPanGestureRecognizer()
    
    var sceneHasPortal: Bool = false
    
    var searchVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "searchVC") as! SearchViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        configureLighting()
        
        actionLabel.text = "Tap on the Screen!"
        
        actionLabel.frame = CGRect(x: 15, y: 25, width: self.view.frame.width-30, height: 30)
        actionLabel.clipsToBounds = true
        actionLabel.layer.cornerRadius = 15
        actionLabel.backgroundColor = UIColor(white: 0.8, alpha: 0.75)
        actionLabel.textColor = .black
        actionLabel.textAlignment = NSTextAlignment.center
        view.addSubview(actionLabel)
        
        searchVC.delegate = self
        searchVC.view.layer.cornerRadius = 15
        setUpInfoViewController()
        
        DispatchQueue.main.async {
            self.present(self.searchVC, animated: true, completion: nil)
        }
    }
    
    func setUpInfoViewController() {
        visualEffectView = UIVisualEffectView()
        visualEffectView.frame = self.view.frame
        self.view.addSubview(visualEffectView)
        self.view.sendSubviewToBack(visualEffectView)
        
        if let infoViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "infoVC") as? InfoViewController {
            self.infoViewController = infoViewController
            self.addChild(infoViewController)
            self.view.addSubview(infoViewController.view)
            
            infoViewController.view.frame = CGRect(x: 10, y: self.view.frame.height - infoVCHandleArea, width: self.view.bounds.width - 20, height: infoVCHeight)
            
            infoViewController.view.clipsToBounds = true
            infoViewController.view.layer.cornerRadius = 20
            
            panGestureRecognizer = UIPanGestureRecognizer()
            panGestureRecognizer.addTarget(self, action: #selector(handleDataPan))
            infoViewController.swipeUpArea.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if sceneHasPortal { removeAllNodes() }
        
        actionLabel.text = "Added Portal"
        sceneHasPortal = true
        
        let portalNode = SCNNode()
        portalNode.position = SCNVector3Make(1,0,0)
        
        let doorLeft = Nodes.wall(length: Nodes.LENGTH / 3)
        doorLeft.position = SCNVector3.init(-Nodes.LENGTH / 3 + Nodes.WIDTH / 2, 0, Nodes.LENGTH / 2 - Nodes.WIDTH / 2)
        doorLeft.eulerAngles = SCNVector3.init(0, -90.0.degreesToRadians, 0)
        portalNode.addChildNode(doorLeft)
        
        let doorRight = Nodes.wall(length: Nodes.LENGTH / 3)
        doorRight.position = SCNVector3.init(Nodes.LENGTH / 3 - Nodes.WIDTH / 2, 0, Nodes.LENGTH / 2 - Nodes.WIDTH / 2)
        doorRight.eulerAngles = SCNVector3.init(0, -90.0.degreesToRadians, 0)
        portalNode.addChildNode(doorRight)
        
        let doorAbove = Nodes.wall(height: Nodes.LENGTH / 3)
        doorAbove.position = SCNVector3.init(0, Nodes.LENGTH / 2 - Nodes.WIDTH / 2, Nodes.LENGTH / 2 - Nodes.WIDTH / 2)
        doorAbove.eulerAngles = SCNVector3.init(0, -90.0.degreesToRadians, 0)
        portalNode.addChildNode(doorAbove)
        
        let backWall = Nodes.wall()
        backWall.position = SCNVector3.init(0, 0, -Nodes.LENGTH / 2 + Nodes.WIDTH / 2)
        backWall.eulerAngles = SCNVector3.init(0, 90.0.degreesToRadians, 0)
        portalNode.addChildNode(backWall)
        
        let leftWall = Nodes.wall()
        leftWall.position = SCNVector3.init(-Nodes.LENGTH / 2 + Nodes.WIDTH / 2, 0, 0)
        leftWall.eulerAngles = SCNVector3.init(0, 180.0.degreesToRadians, 0)
        portalNode.addChildNode(leftWall)
        
        let rightWall = Nodes.wall()
        rightWall.position = SCNVector3.init(Nodes.LENGTH / 2 - Nodes.WIDTH / 2, 0, 0)
        portalNode.addChildNode(rightWall)
        
        let ceiling = Nodes.wall(height: Nodes.LENGTH)
        ceiling.position = SCNVector3.init(0, Nodes.HEIGHT / 2 - Nodes.WIDTH / 2, 0)
        ceiling.eulerAngles = SCNVector3.init(0, 0, 90.0.degreesToRadians)
        portalNode.addChildNode(ceiling)
        
        let floor = Nodes.wall(height: Nodes.LENGTH)
        floor.position = SCNVector3.init(0, -Nodes.HEIGHT / 2 + Nodes.WIDTH / 2, 0)
        floor.eulerAngles = SCNVector3.init(0, 0, -90.0.degreesToRadians)
        portalNode.addChildNode(floor)
        
        img1wall1 = Nodes.addImage(parent: leftWall, z: Float(Nodes.LENGTH/6), y: Float(Nodes.HEIGHT/6), image:#imageLiteral(resourceName: "not-found.png"))
        img1wall2 = Nodes.addImage(parent: leftWall, z: -Float(Nodes.LENGTH/6), y: Float(Nodes.HEIGHT/6), image:#imageLiteral(resourceName: "not-found.png"))
        
        img3wall1 = Nodes.addImage(parent: rightWall, z: Float(Nodes.LENGTH/6), y: Float(Nodes.HEIGHT/6), image:#imageLiteral(resourceName: "not-found.png"))
        img3wall2 = Nodes.addImage(parent: rightWall, z: -Float(Nodes.LENGTH/6), y: Float(Nodes.HEIGHT/6), image:#imageLiteral(resourceName: "not-found.png"))
        
        img2wall1 = Nodes.addImage(parent: backWall, z: Float(Nodes.LENGTH/6), y: Float(Nodes.HEIGHT/6), image:#imageLiteral(resourceName: "not-found.png"))
        img2wall2 = Nodes.addImage(parent: backWall, z: -Float(Nodes.LENGTH/6), y: Float(Nodes.HEIGHT/6), image:#imageLiteral(resourceName: "not-found.png"))
        
//        Nodes.changeImage(img1wall1!, #imageLiteral(resourceName: "cloud_upload_white_192x192.png"))
        
        imgs = [img1wall1, img1wall2, img2wall1, img2wall2, img3wall1, img3wall2]
        
        sceneView.scene.rootNode.addChildNode(portalNode)
    }
    
    @objc
    func handleDataPan(recognizer: UIPanGestureRecognizer) {
        if canSwipeUp {
            switch recognizer.state {
            case .began:
                startTransition(state: nextInfoState(), duration: 0.75)
            case .changed:
                let translation = recognizer.translation(in: self.infoViewController.swipeUpArea)
                var fractionComplete = translation.y / infoVCHeight
                fractionComplete = infoVCVisible ? fractionComplete : -fractionComplete
                updateTransition(fractionCompleted: fractionComplete)
            case .ended:
                continueTransition()
            default:
                break
            }
        }
    }
    
    func nextInfoState() -> InfoVCState {
        return infoVCVisible ? .collapsed : .expanded
    }
    
    func animateTransitionIfNeeded(state: InfoVCState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 0.75) {
                switch state {
                case .expanded:
                    self.infoViewController.view.frame.origin.y = self.view.frame.height - self.infoVCHeight
                case .collapsed:
                    self.infoViewController.view.frame.origin.y = self.view.frame.height - self.infoVCHandleArea
                }
            }
            frameAnimator.addCompletion { _ in
                self.infoVCVisible = !self.infoVCVisible
                self.runningAnimations.removeAll()
            }
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
            
            let cornerRadiusAnimator = UIViewPropertyAnimator(duration: duration, curve: .linear) {
                switch state {
                case .expanded:
                    self.infoViewController.view.layer.cornerRadius = 10
                case .collapsed:
                    self.infoViewController.view.layer.cornerRadius = 20
                }
            }
            cornerRadiusAnimator.startAnimation()
            runningAnimations.append(cornerRadiusAnimator)
            
            let blurAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.visualEffectView.effect = UIBlurEffect(style: .dark)
                    
                case .collapsed:
                    self.visualEffectView.effect = nil
                }
            }
            blurAnimator.startAnimation()
            runningAnimations.append(blurAnimator)
            
            let rotateAnimator = UIViewPropertyAnimator(duration: duration, dampingRatio: 1) {
                switch state {
                case .expanded:
                    self.infoViewController.swipeUpImage.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
                case .collapsed:
                    self.infoViewController.swipeUpImage.transform = CGAffineTransform(rotationAngle: 0)
                }
            }
            rotateAnimator.startAnimation()
            runningAnimations.append(rotateAnimator)
        }
    }
    
    func startTransition(state: InfoVCState, duration: TimeInterval) {
        if runningAnimations.isEmpty {
            animateTransitionIfNeeded(state: state, duration: duration)
        }
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateTransition(fractionCompleted: CGFloat) {
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
    }
    
    func continueTransition() {
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
    }
    
    func changeImg(thing: SCNBox, img:UIImage) {
        Nodes.changeImage(thing, img)
    }
    
    func configureLighting() {
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sceneView.session.run(getConfiguration())
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        sceneView.session.pause()
    }
    
    func enableEnvironmentMapWithIntensity(_ intensity: CGFloat) {
        sceneView.scene.lightingEnvironment.intensity = intensity
    }
    
    func getConfiguration() -> ARWorldTrackingConfiguration {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        configuration.isLightEstimationEnabled = true
        return configuration
    }
    
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async {
            if let lightEstimate = self.sceneView.session.currentFrame?.lightEstimate {
                self.enableEnvironmentMapWithIntensity(lightEstimate.ambientIntensity / 50)
            } else {
                self.enableEnvironmentMapWithIntensity(25)
            }
        }
    }
    
    func removeAllNodes() {
        sceneView.scene.rootNode.enumerateChildNodes { (node, stop) in
            node.removeFromParentNode()
        }
    }
    
    func changeName(name: String) {
        infoViewController.name.text! = name
    }
    
    func changeDescript(des: String) {
        infoViewController.descript.text! = des
    }
    
    func changeArtist(art: String) {
        infoViewController.paintings.text! = art
    }
    
    func changeBirthplace(place: String) {
        infoViewController.birthplace.text! = place
    }
    
    @IBAction func search(_ sender: Any) {
        UIView.animate(withDuration: 0.05,
                       animations: {
                        self.searchButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        },
                       completion: { _ in
                        UIView.animate(withDuration: 0.05) {
                            self.searchButton.transform = CGAffineTransform.identity
                        }
        })
        DispatchQueue.main.async {
            self.present(self.searchVC, animated: true, completion: nil)
        }
    }
}
