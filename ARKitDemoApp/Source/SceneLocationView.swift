//
//  SceneLocationView.swift
//  ARKit+CoreLocation
//
//  Created by Andrew Hart on 02/07/2017.
//  Copyright © 2017 Project Dent. All rights reserved.
//


import Foundation
import ARKit
import CoreLocation
import MapKit


@available(iOS 11.0, *)
public protocol SceneLocationViewDelegate: class {
    func sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation)
    func sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: SceneLocationView, position: SCNVector3, location: CLLocation)
    
    func sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: SceneLocationView, node: LocationNode)
    
    func sceneLocationViewDidSetupSceneNode(sceneLocationView: SceneLocationView, sceneNode: SCNNode)
    
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: LocationNode)
    func sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: SceneLocationView, locationNode: SCNNode)
}

public enum LocationEstimateMethod {
    case coreLocationDataOnly
    case mostRelevantEstimate
}

//Класс инкапсулирующий логику работы с дополненной реальностью + геообъектами
//особенность - улучшена точность определения геопозиция для использования с дополненной реальностью
@available(iOS 11.0, *)
public class SceneLocationView: ARSCNView, ARSCNViewDelegate {
    
    private static let sceneLimit = 100.0
    
    public weak var locationDelegate: SceneLocationViewDelegate?
    
    
    public var locationEstimateMethod: LocationEstimateMethod = .mostRelevantEstimate
    
    let locationManager = LocationManager()
    public var showAxesNode = false
    
    private(set) var locationNodes = [LocationNode]()
    private var locationNodeFrom : LocationNode?
    private var locationNodeTo : LocationNode?
    private var locationNodeFrom2 : LocationNode?
    private var locationNodeTo2 : LocationNode?
    private var line : SCNNode?
    private var line2 : SCNNode?
    private var box : SCNNode?
    private var box1 : SCNNode?
    private var box2 : SCNNode?
    private var locationBoxNodes = [LocationNode]()
    private var locationBoxNodeFrom: LocationNode?
    private var locationBoxNodeTo: LocationNode?
    private var locationBoxNodeFrom2: LocationNode?
    private var locationBoxNodeTo2: LocationNode?
    
    private var sceneLocationEstimates = [SceneLocationEstimate]()
    
    public private(set) var sceneNode: SCNNode? {
        didSet {
            if sceneNode != nil {
                for locationNode in locationNodes {
                    sceneNode!.addChildNode(locationNode)
                }
                
                locationDelegate?.sceneLocationViewDidSetupSceneNode(sceneLocationView: self, sceneNode: sceneNode!)
            }
        }
    }
    
    private var updateEstimatesTimer: Timer?
    
    private var didFetchInitialLocation = false
    
    var showFeaturePoints = false
    
    public var orientToTrueNorth = true
    
    
    
    /*    // draw line-node between two vectors
     func getDrawnLineFrom(pos1: SCNVector3,
     toPos2: SCNVector3) -> SCNNode {
     
     let line = lineFrom(vector: pos1, toVector: toPos2)
     let lineInBetween1 = SCNNode(geometry: line)
     return lineInBetween1
     }
     
     // get line geometry between two vectors
     func lineFromm(vector vector1: SCNVector3,
     toVector vector2: SCNVector3) -> SCNGeometry {
     
     let indices: [Int32] = [0, 1]
     let source = SCNGeometrySource(vertices: [vector1, vector2])
     let element = SCNGeometryElement(indices: indices,
     primitiveType: .line)
     return SCNGeometry(sources: [source], elements: [element])
     }
     
     
     */
    
    
    
    //MARK: Setup
    public convenience init() {
        self.init(frame: CGRect.zero, options: nil)
    }
    
    public override init(frame: CGRect, options: [String : Any]? = nil) {
        super.init(frame: frame, options: options)
        finishInitialization()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        finishInitialization()
    }
    
    private func finishInitialization() {
        locationManager.delegate = self
        
        delegate = self
        
        // Show statistics such as fps and timing information
        showsStatistics = false
        
        if showFeaturePoints {
            debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        }
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
    }
    
    public func run() {
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = .horizontal
        
        if orientToTrueNorth {
            configuration.worldAlignment = .gravityAndHeading
        } else {
            configuration.worldAlignment = .gravity
        }
        
        // Run the view's session
        session.run(configuration)
        
        updateEstimatesTimer?.invalidate()
        updateEstimatesTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(SceneLocationView.updateLocationData), userInfo: nil, repeats: true)
    }
    
    public func pause() {
        session.pause()
        updateEstimatesTimer?.invalidate()
        updateEstimatesTimer = nil
    }
    
    @objc private func updateLocationData() {
        removeOldLocationEstimates()
        confirmLocationOfDistantLocationNodes()
        updatePositionAndScaleOfLocationNodes()
    }
    
    public func moveSceneHeadingClockwise() {
        sceneNode?.eulerAngles.y -= Float(1).degreesToRadians
    }
    
    public func moveSceneHeadingAntiClockwise() {
        sceneNode?.eulerAngles.y += Float(1).degreesToRadians
    }
    
    func resetSceneHeading() {
        sceneNode?.eulerAngles.y = 0
    }
    
    
    public func currentScenePosition() -> SCNVector3? {
        guard let pointOfView = pointOfView else {
            return nil
        }
        
        return scene.rootNode.convertPosition(pointOfView.position, to: sceneNode)
    }
    
    public func currentEulerAngles() -> SCNVector3? {
        return pointOfView?.eulerAngles
    }
    
    fileprivate func addSceneLocationEstimate(location: CLLocation) {
        if let position = currentScenePosition() {
            let sceneLocationEstimate = SceneLocationEstimate(location: location, position: position)
            self.sceneLocationEstimates.append(sceneLocationEstimate)
            
            locationDelegate?.sceneLocationViewDidAddSceneLocationEstimate(sceneLocationView: self, position: position, location: location)
        }
    }
    
    private func removeOldLocationEstimates() {
        if let currentScenePosition = currentScenePosition() {
            self.removeOldLocationEstimates(currentScenePosition: currentScenePosition)
        }
    }
    
    private func removeOldLocationEstimates(currentScenePosition: SCNVector3) {
        let currentPoint = CGPoint.pointWithVector(vector: currentScenePosition)
        
        sceneLocationEstimates = sceneLocationEstimates.filter({
            let point = CGPoint.pointWithVector(vector: $0.position)
            
            let radiusContainsPoint = currentPoint.radiusContainsPoint(radius: CGFloat(SceneLocationView.sceneLimit), point: point)
            
            if !radiusContainsPoint {
                locationDelegate?.sceneLocationViewDidRemoveSceneLocationEstimate(sceneLocationView: self, position: $0.position, location: $0.location)
            }
            
            return radiusContainsPoint
        })
    }
    
    func bestLocationEstimate() -> SceneLocationEstimate? {
        let sortedLocationEstimates = sceneLocationEstimates.sorted(by: {
            if $0.location.horizontalAccuracy == $1.location.horizontalAccuracy {
                return $0.location.timestamp > $1.location.timestamp
            }
            
            return $0.location.horizontalAccuracy < $1.location.horizontalAccuracy
        })
        
        return sortedLocationEstimates.first
    }
    
    public func currentLocation() -> CLLocation? {
        if locationEstimateMethod == .coreLocationDataOnly {
            return locationManager.currentLocation
        }
        
        guard let bestEstimate = self.bestLocationEstimate(),
            let position = currentScenePosition() else {
                return nil
        }
        
        return bestEstimate.translatedLocation(to: position)
    }
    
    
    public func addLocationNodeForCurrentPosition(locationNode: LocationNode) {
        guard let currentPosition = currentScenePosition(),
            let currentLocation = currentLocation(),
            let sceneNode = self.sceneNode else {
                return
        }
        
        locationNode.location = currentLocation
        
        ///Location is not changed after being added when using core location data only for location estimates
        if locationEstimateMethod == .coreLocationDataOnly {
            locationNode.locationConfirmed = true
        } else {
            locationNode.locationConfirmed = false
        }
        
        locationNode.position = currentPosition
        
        locationNodes.append(locationNode)
        sceneNode.addChildNode(locationNode)
    }
    
    
    //create Box
    func createBox(position: SCNVector3) -> SCNNode  {
        let box = SCNBox(width: 1, height: 1, length: 1, chamferRadius: 0)
        let boxNode = SCNNode(geometry: box)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.blue
        box.materials = [material]
        boxNode.position = position
        return boxNode
    }
    
    
    
    public func addLocationNodeWithConfirmedLocation(locationNode: LocationNode) {
        if locationNode.location == nil || locationNode.locationConfirmed == false {
            return
        }
        
        updatePositionAndScaleOfLocationNode(locationNode: locationNode, initialSetup: true, animated: false)
        
        locationNodes.append(locationNode)
        sceneNode?.addChildNode(locationNode)
    }
    
    public func addVectorLocationNodeWithConfirmedLocation(locationNodeFrom: LocationNode, locationNodeTo: LocationNode) {
        if locationNodeFrom.location == nil || locationNodeFrom.locationConfirmed == false {
            return
        }
        
        if locationNodeTo.location == nil || locationNodeTo.locationConfirmed == false {
            return
        }
        
        if self.locationNodeTo == nil {
            updatePositionOfLocationNodes(locationNodeFrom: locationNodeFrom, locationNodeTo: locationNodeTo, line: self.line)//, box: self.box1)
            self.locationNodeTo = locationNodeTo
            self.locationNodeFrom = locationNodeFrom
            //self.locationBoxNodeFrom = locationNodeFrom
            //self.locationBoxNodeTo = locationNodeTo
        } else {
            updatePositionOfLocationNodes(locationNodeFrom: locationNodeFrom, locationNodeTo: locationNodeTo, line: self.line2)//, box: self.box2)
            self.locationNodeTo2 = locationNodeTo
            self.locationNodeFrom2 = locationNodeFrom
            //self.locationBoxNodeFrom2 = locationNodeFrom
            //self.locationBoxNodeTo2 = locationNodeTo
        }
    }
    
    
    public func addBoxLocationNodeWithConfirmedLocation(locationNode: LocationNode) {
        if locationNode.location == nil || locationNode.locationConfirmed == false {
            return
        }
        
        //if self.locationBoxNodeTo == nil {
            updatePositionOfLocationNodesDrawBox(locationNode: locationNode, initialSetup: true, animated: false, box: self.box)
            /*self.locationBoxNodeTo = locationNode
        } else {
            updatePositionOfLocationNodesDrawBox(locationNode: locationNode, box: self.box)
            self.locationBoxNodeTo = locationNode
        }*/
        
        locationBoxNodes.append(locationNode)
        sceneNode?.addChildNode(locationNode)
    }
    
    
    
    public func removeLocationNode(locationNode: LocationNode) {
        if let index = locationNodes.index(of: locationNode) {
            locationNodes.remove(at: index)
        }
        
        locationNode.removeFromParentNode()
    }
    
    private func confirmLocationOfDistantLocationNodes() {
        guard let currentPosition = currentScenePosition() else {
            return
        }
        
        for locationNode in locationNodes {
            if !locationNode.locationConfirmed {
                let currentPoint = CGPoint.pointWithVector(vector: currentPosition)
                let locationNodePoint = CGPoint.pointWithVector(vector: locationNode.position)
                
                if !currentPoint.radiusContainsPoint(radius: CGFloat(SceneLocationView.sceneLimit), point: locationNodePoint) {
                    confirmLocationOfLocationNode(locationNode)
                }
            }
        }
        //Natali added
        for locationNode in locationBoxNodes {
            if !locationNode.locationConfirmed {
                let currentPoint = CGPoint.pointWithVector(vector: currentPosition)
                let locationNodePoint = CGPoint.pointWithVector(vector: locationNode.position)
                
                if !currentPoint.radiusContainsPoint(radius: CGFloat(SceneLocationView.sceneLimit), point: locationNodePoint) {
                    confirmLocationOfLocationNode(locationNode)
                }
            }
        }//End
    }
    
    public func locationOfLocationNode(_ locationNode: LocationNode) -> CLLocation {
        if locationNode.locationConfirmed || locationEstimateMethod == .coreLocationDataOnly {
            return locationNode.location!
        }
        
        if let bestLocationEstimate = bestLocationEstimate(),
            locationNode.location == nil ||
                bestLocationEstimate.location.horizontalAccuracy < locationNode.location!.horizontalAccuracy {
            let translatedLocation = bestLocationEstimate.translatedLocation(to: locationNode.position)
            
            return translatedLocation
        } else {
            return locationNode.location!
        }
    }
    
    private func confirmLocationOfLocationNode(_ locationNode: LocationNode) {
        locationNode.location = locationOfLocationNode(locationNode)
        
        locationNode.locationConfirmed = true
        
        locationDelegate?.sceneLocationViewDidConfirmLocationOfNode(sceneLocationView: self, node: locationNode)
    }
    
    func updatePositionAndScaleOfLocationNodes() {
        for locationNode in locationNodes {
            if locationNode.continuallyUpdatePositionAndScale {
                updatePositionAndScaleOfLocationNode(locationNode: locationNode, animated: true)
            }
        }
        if (self.locationNodeFrom != nil) {
            updatePositionOfLocationNodes(locationNodeFrom: self.locationNodeFrom!, locationNodeTo: self.locationNodeTo!, line: self.line)//, box: self.box1)
        }
        if (self.locationNodeFrom2 != nil) {
            updatePositionOfLocationNodes(locationNodeFrom: self.locationNodeFrom2!, locationNodeTo: self.locationNodeTo2!, line: self.line2)//, box: self.box2)
        }
        //Natali added
        for locationNode in locationBoxNodes {
            if locationNode.continuallyUpdatePositionAndScale {
                updatePositionOfLocationNodesDrawBox(locationNode: locationNode, box: self.box)
            }
        }
        //if (self.locationBoxNodeTo != nil) {
            //updatePositionOfLocationNodesDrawBox(locationNode: self.locationBoxNodeTo!, box: self.box)
        //}
        /*if (self.locationBoxNodeTo2 != nil) {
            updatePositionOfLocationNodesDrawBox(locationNode: self.locationBoxNodeTo2!, box: self.box2)
        }*/
    }
    
    public func updatePositionAndScaleOfLocationNode(locationNode: LocationNode, initialSetup: Bool = false, animated: Bool = false, duration: TimeInterval = 0.1) {
        guard let currentPosition = currentScenePosition(),
            let currentLocation = currentLocation() else {
                return
        }
        
        SCNTransaction.begin()
        
        if animated {
            SCNTransaction.animationDuration = duration
        } else {
            SCNTransaction.animationDuration = 0
        }
        
        let locationNodeLocation = locationOfLocationNode(locationNode)
        
        let locationTranslation = currentLocation.translation(toLocation: locationNodeLocation)
        
        
        let adjustedDistance: CLLocationDistance
        
        let distance = locationNodeLocation.distance(from: currentLocation)
        
        if locationNode.locationConfirmed &&
            (distance > 100 || locationNode.continuallyAdjustNodePositionWhenWithinRange || initialSetup) {
            if distance > 100 {
                //If the item is too far away, bring it closer and scale it down
                let scale = 100 / Float(distance)
                
                adjustedDistance = distance * Double(scale)
                
                let adjustedTranslation = SCNVector3(
                    x: Float(locationTranslation.longitudeTranslation) * scale,
                    y: Float(locationTranslation.altitudeTranslation) * scale,
                    z: Float(locationTranslation.latitudeTranslation) * scale)
                
                let position = SCNVector3(
                    x: currentPosition.x + adjustedTranslation.x,
                    y: currentPosition.y + adjustedTranslation.y,
                    z: currentPosition.z - adjustedTranslation.z)
                
                locationNode.position = position
                
                locationNode.scale = SCNVector3(x: scale, y: scale, z: scale)
            } else {
                adjustedDistance = distance
                let position = SCNVector3(
                    x: currentPosition.x + Float(locationTranslation.longitudeTranslation),
                    y: currentPosition.y + Float(locationTranslation.altitudeTranslation),
                    z: currentPosition.z - Float(locationTranslation.latitudeTranslation))
                
                locationNode.position = position
                locationNode.scale = SCNVector3(x: 1, y: 1, z: 1)
            }
        } else {
            //Calculates distance based on the distance within the scene, as the location isn't yet confirmed
            adjustedDistance = Double(currentPosition.distance(to: locationNode.position))
            
            locationNode.scale = SCNVector3(x: 1, y: 1, z: 1)
        }
        
        if let annotationNode = locationNode as? LocationAnnotationNode {
            //The scale of a node with a billboard constraint applied is ignored
            //The annotation subnode itself, as a subnode, has the scale applied to it
            let appliedScale = locationNode.scale
            locationNode.scale = SCNVector3(x: 1, y: 1, z: 1)
            
            var scale: Float
            
            if annotationNode.scaleRelativeToDistance {
                scale = appliedScale.y
                annotationNode.annotationNode.scale = appliedScale
            } else {
                //Scale it to be an appropriate size so that it can be seen
                scale = Float(adjustedDistance) * 0.181
                
                if distance > 3000 {
                    scale = scale * 0.75
                }
                
                annotationNode.annotationNode.scale = SCNVector3(x: scale, y: scale, z: scale)
            }
            
            annotationNode.pivot = SCNMatrix4MakeTranslation(0, -1.1 * scale, 0)
        }
        
        SCNTransaction.commit()
        
        locationDelegate?.sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: self, locationNode: locationNode)
    }
    
    
    //Func draw line by vectors
    public func updatePositionOfLocationNodes(locationNodeFrom: LocationNode, locationNodeTo: LocationNode, initialSetup: Bool = false, animated: Bool = false, duration: TimeInterval = 0.1, line: SCNNode?) {//}, box: SCNNode?) {
        
        guard let currentPosition = currentScenePosition(),
            let currentLocation = currentLocation() else {
                return
        }
        SCNTransaction.begin()
        if animated {
            SCNTransaction.animationDuration = duration
        } else {
            SCNTransaction.animationDuration = 0
        }
        let locationNodeLocationTo = locationOfLocationNode(locationNodeTo)
        let locationTranslationTo = currentLocation.translation(toLocation: locationNodeLocationTo)
        
        let adjustedTranslationTo = SCNVector3(
            x: Float(locationTranslationTo.longitudeTranslation),
            y: Float(locationTranslationTo.altitudeTranslation),
            z: Float(locationTranslationTo.latitudeTranslation))
        
        let position = SCNVector3(
            x: currentPosition.x + adjustedTranslationTo.x,
            y: currentPosition.y + adjustedTranslationTo.y,
            z: currentPosition.z - adjustedTranslationTo.z)
        
        locationNodeTo.position = position
        
        
        
        let locationNodeLocationFrom = locationOfLocationNode(locationNodeFrom)
        let locationTranslationFrom = currentLocation.translation(toLocation: locationNodeLocationFrom)
        
        let adjustedTranslationFrom = SCNVector3(
            x: Float(locationTranslationFrom.longitudeTranslation),
            y: Float(locationTranslationFrom.altitudeTranslation),
            z: Float(locationTranslationFrom.latitudeTranslation))
        
        let position2 = SCNVector3(
            x: currentPosition.x + adjustedTranslationFrom.x,
            y: currentPosition.y + adjustedTranslationFrom.y,
            z: currentPosition.z - adjustedTranslationFrom.z)
        
        locationNodeFrom.position = position2
        
        SCNTransaction.commit()
        
        //let lineNode = SCNNode(geometry: lineFrom(vector: locationNodeFrom.position, toVector: locationNodeTo.position))
        let lineNode = drawlineNode(from: locationNodeFrom.position, to: locationNodeTo.position, radius: 0.5)
        //let boxNode1 = createBox(position: locationNodeFrom.position)
        //let boxNode2 = createBox(position: locationNodeTo.position)
        if (line == self.line) {
            lineNode.geometry?.firstMaterial?.diffuse.contents = UIColor.red
        }
        if (line != nil) {//}&& (box != nil) {
            sceneNode?.replaceChildNode(line!, with: lineNode)
            //sceneNode?.replaceChildNode(box!, with: boxNode2)
        }
        else {
            sceneNode?.addChildNode(lineNode)
            //sceneNode?.addChildNode(boxNode2)
        }
        if (line == self.line) {//}&& (box == self.box1) {
            self.line = lineNode
            //self.box1 = boxNode2
        }
        else {
            self.line2 = lineNode
            //self.box2 = boxNode2
        }
    }
    
    //line From currently not in use
    func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
        
        let indices: [Int32] = [0, 1]
        //let tube = SCNTube(innerRadius: 0.1, outerRadius: 0.2, height: 1)
        let source = SCNGeometrySource(vertices: [vector1, vector2])
        let element = SCNGeometryElement(indices: indices, primitiveType: .line)
        
        return SCNGeometry(sources: [source], elements: [element])
    }
    
    
    func drawlineNode(from: SCNVector3, to: SCNVector3, radius: CGFloat = 0.25) -> SCNNode {
        let vector = to - from
        let height = vector.length()
        let tube = SCNTube(innerRadius: 0.3, outerRadius: 0.4, height: CGFloat(height))
        let node = SCNNode(geometry: tube)
        node.position = (to + from) / 2
        node.eulerAngles = lineEulerAngles(vector: vector)
        return node
    }
    
    
    func lineEulerAngles(vector: SCNVector3) -> SCNVector3 {
        let height = vector.length()
        let lxz = sqrtf(vector.x * vector.x + vector.z * vector.z)
        let pitchB = vector.y < 0 ? Float.pi - asinf(lxz/height) : asinf(lxz/height)
        let pitch = vector.z == 0 ? pitchB : sign(vector.z) * pitchB
        
        var yaw: Float = 0
        if vector.x != 0 || vector.z != 0 {
            let inner = vector.x / (height * sinf(pitch))
            if inner > 1 || inner < -1 {
                yaw = Float.pi / 2
            } else {
                yaw = asinf(inner)
            }
        }
        return SCNVector3(CGFloat(pitch), CGFloat(yaw), 0)
    }
    
    
    //func for placing box
    public func updatePositionOfLocationNodesDrawBox(locationNode: LocationNode, initialSetup: Bool = false, animated: Bool = false, duration: TimeInterval = 0.1, box: SCNNode?) {
        
        guard let currentPosition = currentScenePosition(),
            let currentLocation = currentLocation() else {
                return
        }
        SCNTransaction.begin()
        if animated {
            SCNTransaction.animationDuration = duration
        } else {
            SCNTransaction.animationDuration = 0
        }
        let locationNodeLocation = locationOfLocationNode(locationNode)
        let locationTranslation = currentLocation.translation(toLocation: locationNodeLocation)
        
        let adjustedTranslation = SCNVector3(
            x: Float(locationTranslation.longitudeTranslation),
            y: Float(locationTranslation.altitudeTranslation),
            z: Float(locationTranslation.latitudeTranslation))
        
        let position = SCNVector3(
            x: currentPosition.x + adjustedTranslation.x,
            y: currentPosition.y + adjustedTranslation.y,
            z: currentPosition.z - adjustedTranslation.z)
        
        locationNode.position = position
        
        SCNTransaction.commit()
        
        var boxNode = createBox(position: locationNode.position)
        locationDelegate?.sceneLocationViewDidUpdateLocationAndScaleOfLocationNode(sceneLocationView: self, locationNode: boxNode)
        locationNode = boxNode
        /*if (box == self.box) {
            boxNode.geometry?.firstMaterial?.diffuse.contents = UIColor.blue
        }*/
    
        /*if (box != nil) {
            sceneNode?.replaceChildNode(box!, with: boxNode)
        } else {*/
            //sceneNode?.addChildNode(boxNode)
        //}
        /*if (box == self.box) {
            self.box = boxNode
        }*/
    }
    
    
    
    
    
    
    
    
    
    
    //MARK: ARSCNViewDelegate
    
    public func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        if sceneNode == nil {
            sceneNode = SCNNode()
            scene.rootNode.addChildNode(sceneNode!)
            
            if showAxesNode {
                let axesNode = SCNNode.axesNode(quiverLength: 0.1, quiverThickness: 0.5)
                sceneNode?.addChildNode(axesNode)
            }
        }
        
        if !didFetchInitialLocation {
            if session.currentFrame != nil,
                let currentLocation = self.locationManager.currentLocation {
                didFetchInitialLocation = true
                
                self.addSceneLocationEstimate(location: currentLocation)
            }
        }
    }
    
    func renderer(aRenderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
        //Makes the lines thicker
        glLineWidth(500)
    }
    
    public func sessionWasInterrupted(_ session: ARSession) {
        print("session was interrupted")
    }
    
    public func sessionInterruptionEnded(_ session: ARSession) {
        print("session interruption ended")
    }
    
    public func session(_ session: ARSession, didFailWithError error: Error) {
        print("session did fail with error: \(error)")
    }
    
    public func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        switch camera.trackingState {
        case .limited(.insufficientFeatures):
            print("camera did change tracking state: limited, insufficient features")
        case .limited(.excessiveMotion):
            print("camera did change tracking state: limited, excessive motion")
        case .limited(.initializing):
            print("camera did change tracking state: limited, initializing")
        case .normal:
            print("camera did change tracking state: normal")
        case .notAvailable:
            print("camera did change tracking state: not available")
        case .limited(.relocalizing):
            break
        }
    }
}

//MARK: LocationManager
@available(iOS 11.0, *)
extension SceneLocationView: LocationManagerDelegate {
    func locationManagerDidUpdateLocation(_ locationManager: LocationManager, location: CLLocation) {
        addSceneLocationEstimate(location: location)
    }
    
    func locationManagerDidUpdateHeading(_ locationManager: LocationManager, heading: CLLocationDirection, accuracy: CLLocationAccuracy) {
        
    }
}


