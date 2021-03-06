//
//  Object.swift
//  SwiftRPG
//
//  Created by 兎澤佑 on 2015/08/04.
//  Copyright © 2015年 兎澤佑. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit

/// ゲーム画面上に配置されるオブジェクトに対応する，SKSpriteNode のラッパークラス(タイル上ではない)
public class Object: MapObject {
    /// オブジェクト名
    private(set) var name: String!

    /// オブジェクトの画像イメージ
    private let images: IMAGE_SET?
    
    /// ノード
    private let object: SKSpriteNode
    
    /// スピード
    private(set) var speed: CGFloat
    
    /// 向き
    private(set) var direction: DIRECTION
    
    /// 画面上の描画位置
    private(set) var position: CGPoint

    /// 歩行のためのインデックス
    /// 0 のときと 1 のときで左足を出すか右足を出すかかわる．0 と 1 の間で toggle する
    private var stepIndex: Int = 0

    // MARK: - MapObject

    private(set) var hasCollision: Bool

    private var events_: [EventListener] = []
    var events: [EventListener] {
        get {
            return self.events_
        }
        set {
            self.events_ = newValue
        }
    }

    private var parent_: MapObject?
    var parent: MapObject? {
        get {
            return self.parent_
        }
        set {
            self.parent_ = newValue
        }
    }

    func setCollision() {
        self.hasCollision = true
    }

    // MARK: -

    init(name: String, position: CGPoint, images: IMAGE_SET?) {
        object = SKSpriteNode()
        object.name = name
        self.name = name
        object.anchorPoint = CGPointMake(0.5, 0.0)
        object.position = position
        speed = 0.2
        direction = DIRECTION.DOWN
        self.hasCollision = false
        self.images = images
        self.position = position
    }

    convenience init(name: String, imageName: String, position: CGPoint, images: IMAGE_SET?) {
        self.init(name: name, position: position, images: images)
        object.texture = SKTexture(imageNamed: imageName)
        object.size = CGSize(width: (object.texture?.size().width)!,
                              height: (object.texture?.size().height)!)
    }

    convenience init(name: String, imageData: UIImage, position: CGPoint, images: IMAGE_SET?) {
        self.init(name: name, position: position, images: images)
        object.texture = SKTexture(image: imageData)
        object.size = CGSize(width: (object.texture?.size().width)!,
                              height: (object.texture?.size().height)!)
    }

    ///  オブジェクトを子ノードとして追加する
    ///
    ///  - parameter node: オブジェクトを追加するノード
    func addTo(node: SKSpriteNode) {
        node.addChild(self.object)
    }

    ///  オブジェクトが対象座標へ直線移動するためのアニメーションを返す
    ///  移動時のテクスチャ変更も含めて行う
    ///  TODO: テクスチャ画像も引数として渡せるように変更する
    ///
    ///  - parameter destination: 目標地点
    ///
    ///  - returns: 目標地点へ移動するアニメーション
    func getActionTo(departure: CGPoint, destination: CGPoint) -> Array<SKAction> {
        var actions: Array<SKAction> = []
        let diff = CGPointMake(destination.x - departure.x,
                               destination.y - departure.y)
        var nextTextures: [SKTexture] = []

        if let images = self.images {
            if (diff.x > 0 && diff.y == 0) {
                self.direction = DIRECTION.RIGHT
                nextTextures = []
                for image in images.RIGHT[self.stepIndex] {
                    nextTextures.append(SKTexture(imageNamed: image))
                    self.stepIndex = abs(self.stepIndex-1)
                }
            } else if (diff.x < 0 && diff.y == 0) {
                self.direction = DIRECTION.LEFT
                nextTextures = []
                for image in images.LEFT[self.stepIndex] {
                    nextTextures.append(SKTexture(imageNamed: image))
                    self.stepIndex = abs(self.stepIndex-1)
                }
            } else if (diff.x == 0 && diff.y > 0) {
                self.direction = DIRECTION.UP
                nextTextures = []
                for image in images.UP[self.stepIndex] {
                    nextTextures.append(SKTexture(imageNamed: image))
                    self.stepIndex = abs(self.stepIndex-1)
                }
            } else if (diff.x == 0 && diff.y < 0) {
                self.direction = DIRECTION.DOWN
                nextTextures = []
                for image in images.DOWN[self.stepIndex] {
                    nextTextures.append(SKTexture(imageNamed: image))
                    self.stepIndex = abs(self.stepIndex-1)
                }
            }
        } else {
            nextTextures = [self.object.texture!]
        }

        let walkAction: SKAction = SKAction.animateWithTextures(nextTextures, timePerFrame: NSTimeInterval(self.speed/2))
        let moveAction: SKAction = SKAction.moveByX(diff.x, y: diff.y, duration: NSTimeInterval(self.speed))
        actions = [SKAction.group([walkAction, moveAction])]

        return actions
    }

    ///  連続したアクションを実行する
    ///  アクション実行中は，他のイベントの発生は無視する
    ///  オブジェクトの位置情報の更新も行う
    ///
    ///  - parameter actions:     実行するアクション
    ///  - parameter destination: 最終目的地
    ///  - parameter callback:    実行終了時に呼ばれるコールバック関数ß
    func runAction(actions: Array<SKAction>, destination: CGPoint, callback: () -> Void) {
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        let sequence: SKAction = SKAction.sequence(actions)
        self.object.runAction(
            sequence,
            completion:
            {
                UIApplication.sharedApplication().endIgnoringInteractionEvents()
                callback()
                // TODO: 現状，最終的な目的地にオブジェクトの位置情報を更新する．リアルタイムに更新できないか？
                self.position = destination
            }
        )
    }

    ///  オブジェクトの方向を指定する．
    ///  画像が存在すれば，方向に応じて適切な画像に切り替える．
    ///
    ///  - parameter direction: オブジェクトの向く方向
    func setDirection(direction: DIRECTION) {
        self.direction = direction
        if let images = self.images {
            let imageNames = images.get(direction)
            self.object.texture = SKTexture(imageNamed: imageNames[0][1])
        }
    }

    ///  オブジェクト(SKNode)の現在位置を取得する．
    ///  座標と同期して管理される Object との位置とは違い，画面上の現在位置を取得する．
    ///
    ///  - returns: SKNode の画面上の位置
    func getRealTimePosition() -> CGPoint {
        return self.object.position
    }

    ///  オブジェクトの Z 軸方向の位置を指定する．
    ///
    ///  - parameter position: z軸方向の位置
    func setZPosition(position: CGFloat) {
        self.object.zPosition = position
    }

    // MARK: - class method

    ///  オブジェクトを生成する
    ///
    ///  - parameter tiles:           生成済みのタイル群．本メソッド内で内容を書き換えられる可能性有り．
    ///  - parameter properties:      タイル及びオブジェクトのプロパティ群
    ///  - parameter tileSets:        タイルセットの情報
    ///  - parameter objectPlacement: オブジェクトの配置情報
    ///
    ///  - throws:
    ///
    ///  - returns: 生成したオブジェクト群
    class func createObjects(
        tiles: Dictionary<TileCoordinate, Tile>,
        properties: Dictionary<TileID, TileProperty>,
        tileSets: Dictionary<TileSetID, TileSet>,
        objectPlacement: Dictionary<TileCoordinate, Int>
    ) throws -> Dictionary<TileCoordinate, [Object]> {
        var objects: Dictionary<TileCoordinate, [Object]> = [:]
        for (coordinate, _) in tiles {
            objects[coordinate] = []
        }

        // オブジェクトの配置
        for (coordinate, _) in tiles {
            let id = objectPlacement[coordinate]
            if id == nil {
                throw MapObjectError.FailedToGenerate("Coordinate(\(coordinate.description)) specified in tiles is not defined at objectPlacement")
            }
            let objectID = id!

            // 該当箇所にオブジェクトが存在しない場合，無視
            if objectID == 0 { continue }

            let property = properties[objectID]
            if property == nil {
                throw MapObjectError.FailedToGenerate("ObjectID \(objectID.description)'s property is not defined in properties")
            }

            let tileSetID = Int(property!["tileSetID"]!)
            if tileSetID == nil {
                throw MapObjectError.FailedToGenerate("tileSetID is not defined in objectID \(objectID.description)'s property(\(property?.description))")
            }

            let tileSet = tileSets[tileSetID!]
            if tileSet == nil {
                throw MapObjectError.FailedToGenerate("tileSet(ID = \(tileSetID?.description)) is not defined in tileSets(\(tileSets.description))")
            }

            let obj_image: UIImage?
            do {
                obj_image = try tileSet?.cropTileImage(objectID)
            } catch {
                throw MapObjectError.FailedToGenerate("Failed to crop image of object which objectID is \(objectID.description)")
            }

            let tileSetName = property!["tileSetName"]
            if tileSetName == nil {
                throw MapObjectError.FailedToGenerate("tileSetName is not defined in objectID \(objectID.description)'s property(\(property?.description))")
            }
            // 一意の名前
            let name = tileSetName! + "_" + NSUUID().UUIDString

            let object = Object(
                name: name,
                imageData: obj_image!,
                position: TileCoordinate.getSheetCoordinateFromTileCoordinate(coordinate),
                images: nil
            )
            objects[coordinate]!.append(object)

            // 当たり判定の付加
            // TODO: タイルではなくオブジェクトに当たり判定をつける
            if let hasCollision = property!["collision"] {
                if hasCollision == "1" {
                    tiles[coordinate]?.setCollision()
                }
            }

            // イベントの付加
            if let obj_action = property!["event"] {
                let tmp = obj_action.componentsSeparatedByString(",")
                let eventType = tmp[0]
                let eventPlacedDirectionsFromParent = tmp[1]
                let eventArgs = Array(tmp.dropFirst().dropFirst())

                let eventListenerErrorMessage = "Error occured at the time of generating event listener: "
                do {
                    if eventPlacedDirectionsFromParent[0] == "1" {
                        try Object.addEventObject(&objects, id: eventType, args: eventArgs, coordinate: coordinate, directionFromParent: .UP)
                    }
                    if eventPlacedDirectionsFromParent[1] == "1" {
                        try Object.addEventObject(&objects, id: eventType, args: eventArgs, coordinate: coordinate, directionFromParent: .DOWN)
                    }
                    if eventPlacedDirectionsFromParent[2] == "1" {
                        try Object.addEventObject(&objects, id: eventType, args: eventArgs, coordinate: coordinate, directionFromParent: .LEFT)
                    }
                    if eventPlacedDirectionsFromParent[3] == "1" {
                        try Object.addEventObject(&objects, id: eventType, args: eventArgs, coordinate: coordinate, directionFromParent: .RIGHT)
                    }
                } catch EventListenerError.IllegalArguementFormat(let string) {
                    throw MapObjectError.FailedToGenerate(eventListenerErrorMessage + string)
                } catch EventListenerError.IllegalParamFormat(let string) {
                    throw MapObjectError.FailedToGenerate(eventListenerErrorMessage + string)
                } catch EventListenerError.InvalidParam(let string) {
                    throw MapObjectError.FailedToGenerate(eventListenerErrorMessage + string)
                } catch EventListenerError.ParamIsNil {
                    throw MapObjectError.FailedToGenerate(eventListenerErrorMessage + "Required param is nil")
                } catch EventGeneratorError.EventIdNotFound {
                    throw MapObjectError.FailedToGenerate(eventListenerErrorMessage + "Specified event type is invalid. Check event method's arguement in json map file")
                } catch EventGeneratorError.InvalidParams(let string) {
                    throw MapObjectError.FailedToGenerate(eventListenerErrorMessage + string)
                } catch {
                    throw MapObjectError.FailedToGenerate(eventListenerErrorMessage + "Unexpected error occured")
                }
            }
        }
        return objects
    }

    private class func addEventObject(
        inout objects: Dictionary<TileCoordinate, [Object]>,
              id: String, args: [String],
              coordinate: TileCoordinate,
              directionFromParent: DIRECTION
    ) throws {
        let eventPlacedTileCoordinate = Object.getTileCoordinateTo(directionFromParent, base: coordinate)
        let eventPlacedSheetCoordinate = TileCoordinate.getSheetCoordinateFromTileCoordinate(eventPlacedTileCoordinate)
        let event: EventListener
        do {
            event = try EventListenerGenerator.getListenerByID(id, directionToParent: directionFromParent.reverse, params: args)
        } catch {
            throw error
        }
        let object = Object(name: "", position: eventPlacedSheetCoordinate, images: nil)
        object.events.append(event)

        objects[eventPlacedTileCoordinate]!.append(object)
    }

    private class func getTileCoordinateTo(direction: DIRECTION, base: TileCoordinate) -> TileCoordinate {
        let placementCoordinate: TileCoordinate

        switch direction {
        case .LEFT:
            placementCoordinate = TileCoordinate(x: base.x-1, y: base.y)
        case .RIGHT:
            placementCoordinate = TileCoordinate(x: base.x+1, y: base.y)
        case .DOWN:
            placementCoordinate = TileCoordinate(x: base.x, y: base.y-1)
        case .UP:
            placementCoordinate = TileCoordinate(x: base.x, y: base.y+1)
        }

        return placementCoordinate
    }

    // MARK: -
}

