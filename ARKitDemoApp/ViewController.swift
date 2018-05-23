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

    @IBOutlet var sceneView: ARSCNView!
    let scene = SCNScene()
    var infoLabel = UILabel(frame: CGRect(x: CGFloat(0), y: CGFloat(0),
                                          width: CGFloat(100), height: CGFloat(50)))
    var infoView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

        
        sceneLocationView.run()
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
        let pinCoordinate1 = CLLocationCoordinate2D(latitude: 55.744323, longitude: 37.560019)
        let pinCoordinate2 = CLLocationCoordinate2D(latitude: 55.744253, longitude: 37.560910)
        let pinCoordinate3 = CLLocationCoordinate2D(latitude: 55.744026, longitude: 37.559644)
        let pinCoordinate4 = CLLocationCoordinate2D(latitude: 55.743924, longitude: 37.560980)
        
        //Nagatinskaya
        //let pinCoordinate1 = CLLocationCoordinate2D(latitude: 55.610792, longitude: 37.698402)
        //let pinCoordinate2 = CLLocationCoordinate2D(latitude: 55.609599, longitude: 37.697178)
        
        //Naro-Fominsk
        //let pinCoordinate1 = CLLocationCoordinate2D(latitude: 55.388110, longitude: 36.751822)
        //let pinCoordinate2 = CLLocationCoordinate2D(latitude: 55.387673, longitude: 36.751586)
        let altitude:Double = 130
        
        let pinLocation1 = CLLocation(coordinate: pinCoordinate1, altitude: altitude)
        let image1 = UIImage(named: "infoPipe")!
        let annotationNode1 = LocationAnnotationNode(location: pinLocation1, image: image1)
        
        let pinLocation2 = CLLocation(coordinate: pinCoordinate2, altitude: altitude)
        let annotationNode2 = LocationAnnotationNode(location: pinLocation2, image: image1)
        
        let pinLocation3 = CLLocation(coordinate: pinCoordinate3, altitude: altitude)
        let annotationNode3 = LocationAnnotationNode(location: pinLocation3, image: image1)
        
        let pinLocation4 = CLLocation(coordinate: pinCoordinate4, altitude: altitude)
        let annotationNode4 = LocationAnnotationNode(location: pinLocation4, image: image1)
        
        sceneLocationView.addVectorLocationNodeWithConfirmedLocation(locationNodeFrom: annotationNode3, locationNodeTo: annotationNode1)
        sceneLocationView.addVectorLocationNodeWithConfirmedLocation(locationNodeFrom: annotationNode1, locationNodeTo: annotationNode2)
        //sceneLocationView.addVectorLocationNodeWithConfirmedLocation(locationNodeFrom: annotationNode2, locationNodeTo: annotationNode4)
        //sceneLocationView.addVectorLocationNodeWithConfirmedLocation(locationNodeFrom: annotationNode3, locationNodeTo: annotationNode4)
        //sceneLocationView.addBoxLocationNodeWithConfirmedLocation(locationNode: annotationNode1)
        sceneLocationView.addBoxLocationNodeWithConfirmedLocation(locationNode: annotationNode4)
        
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




