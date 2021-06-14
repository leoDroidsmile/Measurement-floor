//
//  ViewController.swift
//  Measure
//
//  Created by levantAJ on 8/9/17.
//  Copyright © 2017 levantAJ. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

final class ViewController: UIViewController {
    
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var targetImageView: UIImageView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var meterImageView: UIImageView!
    @IBOutlet weak var resetImageView: UIImageView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var viewButton: UIButton!
    
    fileprivate lazy var session = ARSession()
    fileprivate lazy var sessionConfiguration = ARWorldTrackingConfiguration()
    fileprivate lazy var isMeasuring = false;
    fileprivate lazy var vectorZero = SCNVector3()
    fileprivate lazy var startValue = SCNVector3()
    fileprivate lazy var endValue = SCNVector3()
    fileprivate lazy var lines: [Line] = []
    fileprivate var currentLine: Line?
    fileprivate lazy var unit: DistanceUnit = .foot
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewButton.layer.cornerRadius = 5
        viewButton.layer.masksToBounds = true
        
        setupScene()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden = true
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
        self.navigationController?.isNavigationBarHidden = false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetValues()
        isMeasuring = true
        targetImageView.image = UIImage(named: "targetGreen")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMeasuring = false
        targetImageView.image = UIImage(named: "targetWhite")
        if let line = currentLine {
            lines.append(line)
            currentLine = nil
            resetButton.isHidden = false
            resetImageView.isHidden = false
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - ARSCNViewDelegate

extension ViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            self?.detectObjects()
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        messageLabel.text = "Error occurred"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        messageLabel.text = "Interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        messageLabel.text = "Interruption ended"
    }
}

// MARK: - Users Interactions

extension ViewController {
    @IBAction func meterButtonTapped(button: UIButton) {
        let alertVC = UIAlertController(title: "Settings", message: "Please select distance unit options", preferredStyle: .actionSheet)
        alertVC.addAction(UIAlertAction(title: DistanceUnit.centimeter.title, style: .default) { [weak self] _ in
            self?.unit = .centimeter
        })
        alertVC.addAction(UIAlertAction(title: DistanceUnit.inch.title, style: .default) { [weak self] _ in
            self?.unit = .inch
        })
        alertVC.addAction(UIAlertAction(title: DistanceUnit.meter.title, style: .default) { [weak self] _ in
            self?.unit = .meter
        })
        alertVC.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func viewButtonTapped(button: UIButton) {
        
        
       // var nodeArray = sceneView.scene.rootNode.childNodes
        
//        for childNode in nodeArray {
//
//            if childNode.name == "dot" {
//                print("need")
//            }else{
//                print("not need")
//            }
//        }
        
        
        let image:UIImage = sceneView.snapshot()
//        let ciImage = CIImage(image: image)
//        let resultCI = performRectangleDetection(image: ciImage!)
//        let temimage = convert(cmage: resultCI!)
        
        DispatchQueue.global().async {
                    image.detector.crop(type: .rectangle, padding: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)) { result in
                        DispatchQueue.main.async { [weak self] in
                            switch result {
                            case .success(let cropImageResults):
                                let vc = UIStoryboard.init(name: "Main", bundle: Bundle.main).instantiateViewController(withIdentifier: "DetailsViewController") as? DetailsViewController
                                
                                if let text: String = self?.messageLabel.text {
                                    vc!.temp = "Result : \(text)"
                                    vc?.images = cropImageResults.map { return $0.image }
                                }
                                self?.present(vc!, animated: true, completion: nil)
                                
                            case .notFound(let image, _):
                                
                                print("Not Found")
                            case .failure(let image, _, let error):
                            
                                print(error.localizedDescription)
                            }
                        }
                    }
                }
        
    }
    
    func convert(cmage:CIImage) -> UIImage
    {
        let context:CIContext = CIContext.init(options: nil)
        let cgImage:CGImage = context.createCGImage(cmage, from: cmage.extent)!
        let image:UIImage = UIImage.init(cgImage: cgImage)
        return image
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
    
    func performRectangleDetection(image: CIImage) -> CIImage? {
        var resultImage: CIImage?
        resultImage = image
        let detector = CIDetector(ofType: CIDetectorTypeRectangle, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh, CIDetectorAspectRatio:1.3, CIDetectorMaxFeatureCount: 5] )!
        
        // Get the detections
        var halfPerimiterValue = 0.0 as Float;
        let features = detector.features(in: image)
        print("feature \(features.count)")
        for feature in features as! [CIRectangleFeature] {
            
            let p1 = feature.topLeft
            let p2 = feature.topRight
            let width = hypotf(Float(p1.x - p2.x), Float(p1.y - p2.y));
            //NSLog(@"xaxis    %@", @(p1.x));
            //NSLog(@"yaxis    %@", @(p1.y));
            let p3 = feature.topLeft
            let p4 = feature.bottomLeft
            let height = hypotf(Float(p3.x - p4.x), Float(p3.y - p4.y));
            let currentHalfPerimiterValue = height+width;
            if (halfPerimiterValue < currentHalfPerimiterValue)
            {
                halfPerimiterValue = currentHalfPerimiterValue
                resultImage = cropBusinessCardForPoints(image: image, topLeft: feature.topLeft, topRight: feature.topRight,
                                                        bottomLeft: feature.bottomLeft, bottomRight: feature.bottomRight)
                print("perimmeter   \(halfPerimiterValue)")
            }
            
        }
        
        return resultImage
    }
    
    func cropBusinessCardForPoints(image: CIImage, topLeft: CGPoint, topRight: CGPoint, bottomLeft: CGPoint, bottomRight: CGPoint) -> CIImage {
        
        var businessCard: CIImage
        businessCard = image.applyingFilter(
            "CIPerspectiveTransformWithExtent",
            parameters: [
                "inputExtent": CIVector(cgRect: image.extent),
                "inputTopLeft": CIVector(cgPoint: topLeft),
                "inputTopRight": CIVector(cgPoint: topRight),
                "inputBottomLeft": CIVector(cgPoint: bottomLeft),
                "inputBottomRight": CIVector(cgPoint: bottomRight)])
        businessCard = image.cropped(to: businessCard.extent)
        
        return businessCard
    }
    
    @IBAction func resetButtonTapped(button: UIButton) {
        resetButton.isHidden = true
        resetImageView.isHidden = true
        for line in lines {
            line.removeFromParentNode()
        }
        lines.removeAll()
    }
}

// MARK: - Privates

extension ViewController {
    fileprivate func setupScene() {
        targetImageView.isHidden = true
        sceneView.delegate = self
        sceneView.session = session
        loadingView.startAnimating()
        meterImageView.isHidden = true
        messageLabel.text = "Detecting the world…"
        resetButton.isHidden = true
        resetImageView.isHidden = true
        self.sceneView.debugOptions = []
        sessionConfiguration.planeDetection = [.horizontal,.vertical]
        session.run(sessionConfiguration, options: [.resetTracking, .removeExistingAnchors])
        resetValues()
    }
    
    fileprivate func resetValues() {
        isMeasuring = false
        startValue = SCNVector3()
        endValue =  SCNVector3()
    }
    
    fileprivate func detectObjects() {
        guard let worldPosition = sceneView.realWorldVector(screenPosition: view.center) else { return }
        targetImageView.isHidden = false
        meterImageView.isHidden = false
        if lines.isEmpty {
            messageLabel.text = "Hold screen & move your phone…"
        }
        loadingView.stopAnimating()
        if isMeasuring {
            if startValue == vectorZero {
                startValue = worldPosition
                currentLine = Line(sceneView: sceneView, startVector: startValue, unit: unit)
            }
            endValue = worldPosition
            currentLine?.update(to: endValue)
            messageLabel.text = currentLine?.distance(to: endValue) ?? "Calculating…"
        }
    }
}
