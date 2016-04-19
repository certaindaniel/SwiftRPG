//
//  Item.swift
//  RunTowardTheLight
//
//  Created by Tasuku Tozawa on 2016/04/19.
//  Copyright © 2016年 兎澤佑. All rights reserved.
//

import Foundation
import SpriteKit

/// 配置アイテム
class Item: MapObject {
    /// 当たり判定
    internal var hasCollision: Bool
    
    /// イベント
    internal var event: (EventDispatcher<Any>, [String])?
    
    /// アイテム
    private let item: SKSpriteNode
    
    init(name: String, position: CGPoint, imageName: String) {
        self.hasCollision = false
        item = SKSpriteNode()
        item.name = name
        item.position = position
        item.texture = SKTexture(imageNamed: imageName)
        item.size = CGSize(width: Tile.TILE_SIZE, height: Tile.TILE_SIZE)
    }
    
    func canPass() -> Bool {
        return hasCollision
    }
    
    func setCollision() {
        self.hasCollision = true
    }
    
    func setEvent(event: EventDispatcher<Any>, args: [String]) {
        self.event = (event, args)
    }
    
    func getEvent() -> (EventDispatcher<Any>, [String])? {
        return self.event
    }
    
    func addTo(node: SKSpriteNode) {
        node.addChild(self.item)
    }
    
    func getName() -> String? {
        return self.item.name
    }
}