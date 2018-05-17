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
        
        // Set the view's delegate
        //sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        //sceneView.showsStatistics = true
        
        // Create a new scene
        //let scenePipe = SCNScene(named: "art.scnassets/model.scn")!
        
        
        //createBox()
        //createLine()
        
        
        
        /*let pipeNode = scenePipe.rootNode.childNode(withName: "straight_lo", recursively: true)
        pipeNode?.position = SCNVector3(-0.1, -0.1, -0.3)
        scene.rootNode.addChildNode(pipeNode!)*/
        
        /*let pipeNode2 = pipeNode
        pipeNode2?.position = SCNVector3(-0.1, -0.1, -0.3)
        var originalRotation = pipeNode2?.eulerAngles
        originalRotation?.y = 0.5
        scene.rootNode.addChildNode(pipeNode2!)*/
        
        // Set the scene to the view
        /*sceneView.scene = scene
        drawLine()
        
        labelInfo()
        createView()
        addTapGestureToSceneView()*/
        
        sceneLocationView.run()
        let coordinate = CLLocationCoordinate2D(latitude: 55.610754, longitude: 37.698376)
        let location = CLLocation(coordinate: coordinate, altitude: 130)
        let image = UIImage(named: "infoPipe")!
        
        let annotationNode = LocationAnnotationNode(location: location, image: image)
        //annotationNode.scaleRelativeToDistance = true
        sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
        view.addSubview(sceneLocationView)
        drawLine()
        createView()
    }
    
    
    func drawLine() {
        //Orekhovo
        //let pinCoordinate1 = CLLocationCoordinate2D(latitude: 55.610218, longitude: 37.698873)
        //let pinCoordinate2 = CLLocationCoordinate2D(latitude: 55.609580, longitude: 37.697768)
        
        //Kievskaya
        let pinCoordinate3 = CLLocationCoordinate2D(latitude: 55.744606, longitude: 37.561393)
        let pinCoordinate4 = CLLocationCoordinate2D(latitude: 55.743737, longitude: 37.560079)
        
        //Nagatinskaya
        //let pinCoordinate5 = CLLocationCoordinate2D(latitude: 55.610792, longitude: 37.698402)
        //let pinCoordinate6 = CLLocationCoordinate2D(latitude: 55.609599, longitude: 37.697178)
        
        //Naro-Fominsk
        //let pinCoordinate7 = CLLocationCoordinate2D(latitude: 55.388110, longitude: 36.751822)
        //let pinCoordinate8 = CLLocationCoordinate2D(latitude: 55.387673, longitude: 36.751586)
        // координаты мои, белый цвет
        /*let locationNodeLocation5Translation = SCNVector3(
            x: Float(pinCoordinate1.longitude),
            y: Float(170),
            z: Float(pinCoordinate1.latitude))
        
        let locationNodeLocation6Translation = SCNVector3(
            x: Float(pinCoordinate2.longitude),
            y: Float(150),
            z: Float(pinCoordinate2.latitude))*/
        
        let pinLocation1 = CLLocation(coordinate: pinCoordinate3, altitude: 130)
        let image1 = UIImage(named: "infoPipe")!
        let annotationNode1 = LocationAnnotationNode(location: pinLocation1, image: image1)
        //let locationNodeLocation1 = annotationNode1.location!
        
        let pinLocation2 = CLLocation(coordinate: pinCoordinate4, altitude: 130)
        let image2 = UIImage(named: "infoPipe")!
        let annotationNode2 = LocationAnnotationNode(location: pinLocation2, image: image2)
        //let locationNodeLocation2 = annotationNode2.location!
        
        /*let locationNodeLocation1Translation = SCNVector3(
            x: Float(pinLocation1.coordinate.longitude),
            y: Float(pinLocation1.altitude),
            z: Float(pinLocation1.coordinate.latitude))
        
        let locationNodeLocation2Translation = SCNVector3(
            x: Float(pinLocation2.coordinate.longitude),
            y: Float(pinLocation2.altitude),
            z: Float(pinLocation2.coordinate.latitude))*/
        
        sceneLocationView.addVectorLocationNodeWithConfirmedLocation(locationNodeFrom: annotationNode1, locationNodeTo: annotationNode2)
        sceneLocationView.addBoxLocationNodeWithConfirmedLocation(locationNode: annotationNode1)
        sceneLocationView.addBoxLocationNodeWithConfirmedLocation(locationNode: annotationNode2)
        /*let mat = SCNMaterial()
        
        mat.diffuse.contents  = UIColor.cyan
        mat.specular.contents = UIColor.green
        
        let lineNode = drawLine(v1: locationNodeLocation5Translation, v2: locationNodeLocation6Translation, material: [mat])*/
        //self.sceneView.scene.rootNode.addChildNode(lineNode)
        
        //createBox(vector: locationNodeLocation5Translation)
        //createBox(vector: locationNodeLocation5Translation)
        
        /*let mapView = MKMapView()
        let p = mapView.convert(pinCoordinate1, toPointTo: mapView)
        let t = mapView.convert(pinCoordinate2, toPointTo: mapView)
        let a = SCNVector3Make(Float(p.x), Float(sceneView.bounds.size.height - p.y), -100)
        let b = SCNVector3Make(Float(t.x), Float(sceneView.bounds.size.height - t.y), -100)*/
        
        //let a = scene.rootNode.convertPosition(locationNodeLocation5Translation, to: sceneView.scene.rootNode)
        //let b = scene.rootNode.convertPosition(locationNodeLocation6Translation, to: sceneView.scene.rootNode)
        /*
        let a = sceneLocationView.convertCoordinates(locationNode: annotationNode1, initialSetup: true)
        let b = sceneLocationView.convertCoordinates(locationNode: annotationNode2, initialSetup: true)*/
        /*let line = SCNGeometry.line(from: a, to: b)
        let lineNode1 = SCNNode(geometry: line)
        lineNode1.position = SCNVector3Zero
        sceneView.scene.rootNode.addChildNode(lineNode1)*/
        
    }
    
    
    
    //another way
    func drawLine(v1: SCNVector3, v2: SCNVector3, material: [SCNMaterial]) {
        let  height1 = self.distanceBetweenPoints2(A: v1, B: v2) as CGFloat //v1.distance(v2)
        
        //let position = v1
        
        let ndV2 = SCNNode()
        
        ndV2.position = v2
        
        let ndZAlign = SCNNode()
        ndZAlign.eulerAngles.x = Float.pi/2
        
        //let cylgeo = SCNBox(width: 0.02, height: height1, length: 0.001, chamferRadius: 0)
        let cylgeo = SCNTube(innerRadius: 0.01, outerRadius: 0.02, height: height1)
        cylgeo.materials = material
        
        let ndCylinder = SCNNode(geometry: cylgeo )
        //ndCylinder.position = v1
        
        ndCylinder.position.y = Float(-height1/2) + 0.001
        ndZAlign.addChildNode(ndCylinder)
        
        //self.sceneView.scene.rootNode.addChildNode(ndZAlign)
        
        let constraints = [SCNLookAtConstraint(target: ndV2)]
    }
    
    func distanceBetweenPoints2(A: SCNVector3, B: SCNVector3) -> CGFloat {
        let l = sqrt(
            (A.x - B.x) * (A.x - B.x)
                +   (A.y - B.y) * (A.y - B.y)
                +   (A.z - B.z) * (A.z - B.z)
        )
        return CGFloat(l)
    }
    
    
    //create Box
    func createBox() {
        let box = SCNBox(width: 0.1, height: 0.1, length: 0.1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: box)
        boxNode.position = SCNVector3(-0.1,-0.1,-0.5)
        /*boxNode.position = SCNVector3(
            x: Float(coordinates.longitude),
            y: Float(150),
            z: Float(coordinates.latitude))*/
        //boxNode.convertPosition(vector, to: scene.rootNode)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        box.materials = [material]
        scene.rootNode.addChildNode(boxNode)
    }
    
    func createLine() {
        let line = SCNTube(innerRadius: 0.01, outerRadius: 0.02, height: 5)
        let lineNode = SCNNode(geometry: line)
        lineNode.position = SCNVector3(-0.1,-0.1,-0.5)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.green
        line.materials = [material]
        let action = SCNAction.rotate(by: CGFloat(degToRadians(degrees: -90)), around: lineNode.position, duration: 0)
        lineNode.runAction(action)
        //var originalRotation = lineNode.eulerAngles
        //originalRotation.x = 90
        scene.rootNode.addChildNode(lineNode)
    }
    
    func degToRadians(degrees:Double) -> Double {
        return degrees * (.pi / 180);
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
        infoView.removeFromSuperview()
        
    }
    
    func addTapGestureToSceneView() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.didTap(withGestureRecognizer:)))
        sceneLocationView.addGestureRecognizer(tapGestureRecognizer)
    }
    
    /*override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else {
            return
        }
        let location = touch.location(in: self)
        let hit = nodes(at: location)
        if let node = hit.first {
            if node.name == "straight_lo" {
                
                sceneView.addSubview(infoLabel)
                
            }
        }
    }*/
    
    
    func labelInfo() {
        infoLabel.font = UIFont.systemFont(ofSize: 10)
        infoLabel.textAlignment = .left
        infoLabel.textColor = UIColor.white
        infoLabel.numberOfLines = 0
        infoLabel.text = "Pipe information"
    }
    
    
    @objc func didTap(withGestureRecognizer recognizer: UIGestureRecognizer) {
        let tapLocation = recognizer.location(in: sceneLocationView)
        let hitTestResults = sceneView.hitTest(tapLocation)
        guard let node = hitTestResults.first?.node else { sceneLocationView.removeFromSuperview(); return }
        
        //node.removeFromParentNode()
        
        //sceneView.addSubview(infoView)
        sceneLocationView.addSubview(infoView)
        
        //let node1 = label()
        //scene.rootNode.addChildNode(node1)
        
        
    }
    
    
    
    
    
    @objc func didTapLabel(node: SCNNode) {
        node.removeFromParentNode()
    }
    
    
    func label() -> SCNNode {
        
        let node = SCNNode()
        let label = UILabel(frame: CGRect(x: CGFloat(0), y: CGFloat(0), width: CGFloat(100), height: CGFloat(50)))
        
        let plane = SCNPlane(width: 0.2, height: 0.1)
        
        label.text = "Pipe information"
        label.adjustsFontSizeToFitWidth = true
        
        plane.firstMaterial?.diffuse.contents = label
        node.geometry = plane
        node.position = SCNVector3(0.1, -0.1, -0.3)
        
        return node
        
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



extension SCNGeometry {
    class func line(from vector1: SCNVector3, to vector2: SCNVector3) -> SCNGeometry {
        let indices: [Int32] = [0, 1]
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        return SCNGeometry(sources: [source], elements: [element])
    }
}


