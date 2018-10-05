//
//  ViewController.swift
//  ARKitDemoApp
//
//  Created by Наталья Синицына on 10.04.2018.
//  Copyright © 2018 Наталья Синицына. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreLocation
import MapKit

class ViewController: UIViewController, ARSCNViewDelegate, MKMapViewDelegate, SceneLocationViewDelegate  {
    
    var sceneLocationView = SceneLocationView()
    let image1 = UIImage(named: "infoPipe")!

    @IBOutlet var sceneView: ARSCNView!
    let scene = SCNScene()
    var infoLabel = UILabel(frame: CGRect(x: CGFloat(0), y: CGFloat(0),
                                          width: CGFloat(100), height: CGFloat(50)))
    var infoView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneLocationView.run()
        //sceneLocationView.orientToTrueNorth = false //if true - worldAligment set to gravityAndHeading, if false = gravity only
        let coordinate = CLLocationCoordinate2D(latitude: 55.610754, longitude: 37.698376)
        let location = CLLocation(coordinate: coordinate, altitude: 130)
        let image = UIImage(named: "infoPipe")!
        
        let annotationNode = LocationAnnotationNode(location: location, image: image)
        //annotationNode.scaleRelativeToDistance = true
        //sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        view.addSubview(sceneLocationView)
        drawLine()
        createView()
        addTapGestureToSceneView()
    }
    
    
    func drawLine() {
        //Orekhovo
        /*let pinCoordinate1 = CLLocationCoordinate2D(latitude: 55.610218, longitude: 37.698873)
        let pinCoordinate2 = CLLocationCoordinate2D(latitude: 55.609580, longitude: 37.697768)
        let pinCoordinate3 = CLLocationCoordinate2D(latitude: 55.610664, longitude: 37.697487)
        let pinCoordinate4 = CLLocationCoordinate2D(latitude: 55.610072, longitude: 37.696591)*/
        
        //Kievskaya
        let pinCoordinate1 = CLLocationCoordinate2D(latitude: 55.746844, longitude: 37.571222)
        let pinCoordinate2 = CLLocationCoordinate2D(latitude: 55.746331, longitude: 37.572041)
        let pinCoordinate3 = CLLocationCoordinate2D(latitude: 55.746945, longitude: 37.572273)
        let pinCoordinate4 = CLLocationCoordinate2D(latitude: 55.747183, longitude: 37.571653)
        
        let kievskayaArray = [pinCoordinate1, pinCoordinate2, pinCoordinate3, pinCoordinate4]
        
        //Nagatinskaya
        //let pinCoordinate1 = CLLocationCoordinate2D(latitude: 55.610792, longitude: 37.698402)
        //let pinCoordinate2 = CLLocationCoordinate2D(latitude: 55.609599, longitude: 37.697178)
        
        //Naro-Fominsk
        //let pinCoordinate1 = CLLocationCoordinate2D(latitude: 55.388110, longitude: 36.751822)
        //let pinCoordinate2 = CLLocationCoordinate2D(latitude: 55.387673, longitude: 36.751586)
        
        
        //From TopoOsnovi
        let coord1 = CLLocationCoordinate2D(latitude: 36.760367898604116, longitude: 55.367471669509968)
        let coord2 = CLLocationCoordinate2D(latitude: 36.741295019096128, longitude: 55.368076328771217)
        let coord3 = CLLocationCoordinate2D(latitude: 36.722512369273069, longitude: 55.369712529211597)
        let coord4 = CLLocationCoordinate2D(latitude: 36.727147989353206, longitude: 55.369760659267122)
        let coord5 = CLLocationCoordinate2D(latitude: 36.726680897900465, longitude: 55.369885619210557)
        let coord6 = CLLocationCoordinate2D(latitude: 36.726889438155055, longitude: 55.370270188929318)
        let coord7 = CLLocationCoordinate2D(latitude: 36.732702159637263, longitude: 55.372679849594263)
        let coord8 = CLLocationCoordinate2D(latitude: 36.739952479786297, longitude: 55.373548619407885)
        let coord9 = CLLocationCoordinate2D(latitude: 36.725798708383117, longitude: 55.374056229117521)
        let coord10 = CLLocationCoordinate2D(latitude: 36.747889238711807, longitude: 55.374074519391691)
        let coord11 = CLLocationCoordinate2D(latitude: 36.760547169051158, longitude: 55.374927549257833)
        let coord12 = CLLocationCoordinate2D(latitude: 36.754914339638624, longitude: 55.374962269190966)
        let coord13 = CLLocationCoordinate2D(latitude: 36.756509969683449, longitude: 55.375527799747097)
        let coord14 = CLLocationCoordinate2D(latitude: 36.761839618472813, longitude: 55.376734269154156)
        let coord15 = CLLocationCoordinate2D(latitude: 36.764187148969846, longitude: 55.377428159416219)
        let coord16 = CLLocationCoordinate2D(latitude: 36.761386909493012, longitude: 55.379232709215664)
        let coord17 = CLLocationCoordinate2D(latitude: 36.756674168462204, longitude: 55.387049118760281)
        let coord18 = CLLocationCoordinate2D(latitude: 36.756229038374919, longitude: 55.387430909904936)
        
        let altitude:Double = 130
        
        let coordArray = [coord1, coord2, coord3, coord4, coord5, coord6, coord7, coord8, coord9, coord10, coord11, coord12, coord13, coord14, coord15, coord16, coord17, coord18]
        
        for (i, _) in coordArray.enumerated() {
            if i < coordArray.count-1 {
                createVector(firstCoordinate: coordArray[i], secondCoordinate: coordArray[i+1], altitude: altitude)
            }
        }
        
        for (i, _) in kievskayaArray.enumerated() {
            if i < kievskayaArray.count-1 {
                createVector(firstCoordinate: kievskayaArray[i], secondCoordinate: kievskayaArray[i+1], altitude: altitude)
            }
        }
        
        
        /*createVector(firstCoordinate: pinCoordinate1, secondCoordinate: pinCoordinate2, altitude: altitude)
        createVector(firstCoordinate: pinCoordinate2, secondCoordinate: pinCoordinate3, altitude: altitude)
        createVector(firstCoordinate: pinCoordinate3, secondCoordinate: pinCoordinate4, altitude: altitude)*/
        
        
        //sceneLocationView.addBoxLocationNodeWithConfirmedLocation(locationNode: annotationNode1)
        //sceneLocationView.addBoxLocationNodeWithConfirmedLocation(locationNode: annotationNode4)
        
    }
    
    
    func createVector(firstCoordinate: CLLocationCoordinate2D, secondCoordinate: CLLocationCoordinate2D, altitude: Double) {
        let pinLocation1 = CLLocation(coordinate: firstCoordinate, altitude: altitude)
        let annotationNode1 = LocationAnnotationNode(location: pinLocation1, image: image1)
        let pinLocation2 = CLLocation(coordinate: secondCoordinate, altitude: altitude)
        let annotationNode2 = LocationAnnotationNode(location: pinLocation2, image: image1)
        
        sceneLocationView.addVectorLocationNodeWithConfirmedLocation(locationNodeFrom: annotationNode1, locationNodeTo: annotationNode2)
    }
    
    
    
    func createView() {
        let imageName = "infoPipe.png"
        let image = UIImage(named: imageName)
        let imageView = UIImageView(image: image!)
        infoView.frame = CGRect(x: 150, y: 150,
        width: CGFloat(50), height: CGFloat(100))
        infoView.addSubview(imageView)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(ViewController.imageTapped(withGestureRecognizer:)))
        //tap.delegate = self
        infoView.addGestureRecognizer(tap)
        
        /*let node = SCNNode()
        let plane = SCNPlane(width: 0.2, height: 0.1)
        plane.firstMaterial?.diffuse.contents = infoView
        node.geometry = plane
        node.position = SCNVector3(0.1, -0.1, -0.4)*/
    }
    
    @objc func imageTapped(withGestureRecognizer recognizer: UIGestureRecognizer) {
        //infoView.removeFromSuperview()
        sceneLocationView.willRemoveSubview(infoView)
        
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
        sceneLocationView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneLocationView)
        let hitTestResults = sceneLocationView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else { infoView.removeFromSuperview(); return }
        
        //node.removeFromParentNode()
        
        //sceneView.addSubview(infoView)
        sceneLocationView.addSubview(infoView)
        
        //let node1 = label()
        //scene.rootNode.addChildNode(node1)
        
        
    }
    
   
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        //let configuration = ARWorldTrackingConfiguration()
        // Run the view's session
        //sceneView.session.run(configuration)
        
        sceneLocationView.run()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        //sceneView.session.pause()
        
        sceneLocationView.pause()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    // MARK: - ARSCNViewDelegate
    
/*
    // Override to create and configure nodes for anchors added to the view's session.
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        let node = SCNNode()
     
        return node
    }
*/
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        sceneLocationView.frame = view.bounds
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    
    
    //MARK: SceneLocationViewDelegate
    
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        //DDLogDebug("add scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation) {
        //DDLogDebug("remove scene location estimate, position: \(position), location: \(location.coordinate), accuracy: \(location.horizontalAccuracy), date: \(location.timestamp)")
    }
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode) {
    }
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode) {
        
    }
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode) {
        
    }
    
    
}




