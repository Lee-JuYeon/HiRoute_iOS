//
//  GeoObject3DMarkerView.swift
//  HiRoute
//
//  Created by Codex on 5/7/26.
//

import MapKit
import SceneKit
import UIKit

final class GeoObject3DMarkerView: MKAnnotationView {
    static let reuseID = "GeoObject3DMarkerView"

    private let sceneView = SCNView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private var currentObjectID: String?

    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupViews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupViews() {
        backgroundColor = .clear
        isUserInteractionEnabled = true
        canShowCallout = false
        collisionMode = .none
        displayPriority = .required

        let width: CGFloat = 112
        let objectHeight: CGFloat = 82
        let titleTop: CGFloat = 92
        let height: CGFloat = 130
        frame = CGRect(x: 0, y: 0, width: width, height: height)

        sceneView.frame = CGRect(x: 18, y: 0, width: 76, height: objectHeight)
        sceneView.backgroundColor = .clear
        sceneView.isOpaque = false
        sceneView.allowsCameraControl = false
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling2X
        sceneView.preferredFramesPerSecond = 30
        sceneView.rendersContinuously = false
        sceneView.isPlaying = false
        addSubview(sceneView)

        titleLabel.font = .systemFont(ofSize: 10, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.frame = CGRect(x: 0, y: titleTop, width: width, height: 14)
        addSubview(titleLabel)

        subtitleLabel.font = .systemFont(ofSize: 8, weight: .medium)
        subtitleLabel.textAlignment = .center
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.frame = CGRect(x: 0, y: 108, width: width, height: 18)
        addSubview(subtitleLabel)

        // 좌표가 3D 오브젝트의 바닥에 붙도록 맞춘다.
        centerOffset = CGPoint(x: 0, y: objectHeight - (height / 2))
    }

    func configure(with annotation: GeoObjectAnnotation) {
        let object = annotation.geoObject
        titleLabel.text = object.title
        subtitleLabel.text = object.subtitle
        accessibilityLabel = object.title
        accessibilityHint = object.subtitle

        if currentObjectID != object.id {
            let scene = makeScene(for: object)
            scene.isPaused = true
            sceneView.scene = scene
            currentObjectID = object.id
            sceneView.setNeedsDisplay()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        subtitleLabel.text = nil
        currentObjectID = nil
    }

    private func makeScene(for object: GeoObjectModel) -> SCNScene {
        let scene = SCNScene()
        scene.background.contents = UIColor.clear

        let ambient = SCNNode()
        ambient.light = SCNLight()
        ambient.light?.type = .ambient
        ambient.light?.intensity = 700
        ambient.light?.color = UIColor.white
        scene.rootNode.addChildNode(ambient)

        let omni = SCNNode()
        omni.light = SCNLight()
        omni.light?.type = .omni
        omni.light?.intensity = 1200
        omni.light?.color = UIColor.white
        omni.position = SCNVector3(2.5, 3.0, 4.0)
        scene.rootNode.addChildNode(omni)

        let camera = SCNNode()
        camera.camera = SCNCamera()
        camera.camera?.zNear = 0.1
        camera.camera?.zFar = 30
        camera.position = SCNVector3(0, 0.55, 4.5)
        scene.rootNode.addChildNode(camera)

        let root = SCNNode()
        root.scale = SCNVector3(
            Float(object.scale),
            Float(object.scale),
            Float(object.scale)
        )
        scene.rootNode.addChildNode(root)

        let baseRing = SCNTorus(ringRadius: 0.72, pipeRadius: 0.055)
        baseRing.firstMaterial = makeMaterial(color: object.color.withAlphaComponent(0.55))
        let baseNode = SCNNode(geometry: baseRing)
        baseNode.position = SCNVector3(0, -0.62, 0)
        baseNode.eulerAngles.x = .pi / 2
        root.addChildNode(baseNode)

        let pedestal = SCNCylinder(radius: 0.34, height: 0.12)
        pedestal.firstMaterial = makeMaterial(color: UIColor(white: 0.15, alpha: 1.0))
        let pedestalNode = SCNNode(geometry: pedestal)
        pedestalNode.position = SCNVector3(0, -0.48, 0)
        root.addChildNode(pedestalNode)

        let mainNode = makeMainNode(for: object)
        mainNode.position = SCNVector3(0, 0.08, 0)
        root.addChildNode(mainNode)

        let shadowOrb = SCNSphere(radius: 0.18)
        shadowOrb.firstMaterial = makeMaterial(color: object.color.withAlphaComponent(0.22))
        let orbNode = SCNNode(geometry: shadowOrb)
        orbNode.position = SCNVector3(0, 0.72, 0)
        root.addChildNode(orbNode)

        return scene
    }

    private func makeMainNode(for object: GeoObjectModel) -> SCNNode {
        let color = object.color

        switch object.style {
        case .cube:
            let box = SCNBox(width: 0.9, height: 0.9, length: 0.9, chamferRadius: 0.12)
            box.firstMaterial = makeMaterial(color: color)
            let node = SCNNode(geometry: box)
            node.eulerAngles = SCNVector3(0.25, 0.45, 0.0)
            return node

        case .beacon:
            let parent = SCNNode()

            let column = SCNCylinder(radius: 0.22, height: 1.15)
            column.firstMaterial = makeMaterial(color: color)
            let columnNode = SCNNode(geometry: column)
            columnNode.position = SCNVector3(0, 0.28, 0)
            parent.addChildNode(columnNode)

            let cap = SCNSphere(radius: 0.27)
            cap.firstMaterial = makeMaterial(color: color.withAlphaComponent(0.95))
            let capNode = SCNNode(geometry: cap)
            capNode.position = SCNVector3(0, 0.94, 0)
            parent.addChildNode(capNode)

            let fin = SCNCone(topRadius: 0.0, bottomRadius: 0.34, height: 0.42)
            fin.firstMaterial = makeMaterial(color: color.withAlphaComponent(0.75))
            let finNode = SCNNode(geometry: fin)
            finNode.position = SCNVector3(0, -0.36, 0)
            parent.addChildNode(finNode)

            return parent

        case .crystal:
            let pyramid = SCNPyramid(width: 0.95, height: 1.25, length: 0.95)
            pyramid.firstMaterial = makeMaterial(color: color)
            let node = SCNNode(geometry: pyramid)
            node.eulerAngles.y = 0.35
            return node

        case .tower:
            let parent = SCNNode()

            let tower = SCNCylinder(radius: 0.32, height: 1.35)
            tower.firstMaterial = makeMaterial(color: color)
            let towerNode = SCNNode(geometry: tower)
            towerNode.position = SCNVector3(0, 0.22, 0)
            parent.addChildNode(towerNode)

            let roof = SCNCone(topRadius: 0.0, bottomRadius: 0.42, height: 0.55)
            roof.firstMaterial = makeMaterial(color: color.withAlphaComponent(0.9))
            let roofNode = SCNNode(geometry: roof)
            roofNode.position = SCNVector3(0, 1.06, 0)
            parent.addChildNode(roofNode)

            let crown = SCNTorus(ringRadius: 0.4, pipeRadius: 0.05)
            crown.firstMaterial = makeMaterial(color: color.withAlphaComponent(0.6))
            let crownNode = SCNNode(geometry: crown)
            crownNode.position = SCNVector3(0, 0.95, 0)
            crownNode.eulerAngles.x = .pi / 2
            parent.addChildNode(crownNode)

            return parent
        }
    }

    private func makeMaterial(color: UIColor) -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = color
        material.specular.contents = UIColor.white
        material.emission.contents = color.withAlphaComponent(0.25)
        material.metalness.contents = 0.35
        material.roughness.contents = 0.2
        material.lightingModel = .physicallyBased
        material.isDoubleSided = true
        return material
    }
}
