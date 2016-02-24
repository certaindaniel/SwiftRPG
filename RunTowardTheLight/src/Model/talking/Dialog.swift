//
//  dialog.swift
//  RunTowardTheLight
//
//  Created by tasuku tozawa on 2015/08/10.
//  Copyright © 2015年 兎澤佑. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit

class Dialog {
    let FONT_SIZE: CGFloat = 14.0
    let FONT_WIDTH_MARGIN: CGFloat = 1.0
    let FONT_HEIGHT_MARGIN: CGFloat = 5.0
    let PADDING_WIDTH: CGFloat = 20.0
    let PADDING_HEIGHT: CGFloat = 14.0
    let MARGIN: CGFloat = 30.0
    let VIEW_TEXT_TIME: CGFloat = 0.1
    let BUTTON_SIZE: CGFloat = 10.0

    let textBox_: SKShapeNode!
    var boxWidth_: CGFloat!
    var boxHeight_: CGFloat!
    var textRegionWidth_: CGFloat!
    var textRegionHeight_: CGFloat!
    let charRegionWidth_: CGFloat!
    let charRegionHeight_: CGFloat!

    let nextButton_: SKSpriteNode!
    let buttonLoop_: SKAction!

    var rowNum_: CGFloat!
    var colNum_: CGFloat!

    private let frameWidth_: CGFloat!
    private let frameHeight_: CGFloat!

    var characterIcon_: SKSpriteNode!
    let CHAR_ICON_SIZE: CGFloat = 150.0
    let ICON_MARGIN: CGFloat = 10.0


    enum POSITION {
        case top, bottom, middle
    }

    enum TALK_SIDE {
        case left, right, middle
    }

    init(frame_width: CGFloat, frame_height: CGFloat) {
        frameWidth_ = frame_width
        frameHeight_ = frame_height

        boxWidth_ = frameWidth_
        boxHeight_ = 180.0

        // 文字1文字の描画幅
        charRegionWidth_ = FONT_SIZE + FONT_WIDTH_MARGIN
        charRegionHeight_ = FONT_SIZE + FONT_HEIGHT_MARGIN

        // テキスト描画領域のサイズ
        textRegionWidth_ = boxWidth_ - PADDING_WIDTH * 2
        textRegionHeight_ = boxHeight_ - PADDING_HEIGHT * 2

        // テキスト描画領域内に描画可能な最大文字数，行数
        rowNum_ = ceil(textRegionWidth_ / charRegionWidth_)
        colNum_ = ceil(textRegionHeight_ / charRegionHeight_)

        // テキスト描画領域のサイズ最適化
        textRegionWidth_ = rowNum_ * charRegionWidth_
        textRegionHeight_ = colNum_ * charRegionHeight_ - FONT_HEIGHT_MARGIN

        // テキストボックスのサイズ最適化
        // box_width_  = text_region_width_  + PADDING*2
        boxHeight_ = textRegionHeight_ + PADDING_HEIGHT * 2 + BUTTON_SIZE

        // テキストボックスサイズを求める
        let box_shape = CGRectMake(0, 0, boxWidth_, boxHeight_)
        textBox_ = SKShapeNode(rect: box_shape, cornerRadius: 10)
        textBox_.fillColor = SKColor.blackColor()
        textBox_.strokeColor = SKColor.whiteColor()
        textBox_.lineWidth = 2.0
        textBox_.position = CGPointMake(frame_width / 2 - boxWidth_ / 2,
                                        frame_height / 2 - boxHeight_ / 2)

        // ページ送りボタンの設置
        nextButton_ = SKSpriteNode(
            color: UIColor.whiteColor(),
            size: CGSize(width: BUTTON_SIZE, height: BUTTON_SIZE))
        nextButton_.position = CGPointMake(
            PADDING_WIDTH + textRegionWidth_,
            PADDING_HEIGHT)
        let fadeout = SKAction.fadeAlphaTo(0.0, duration: 0.0)
        let fadein = SKAction.fadeAlphaTo(1.0, duration: 0.0)
        let delay = SKAction.waitForDuration(NSTimeInterval(0.5))
        buttonLoop_ = SKAction.repeatActionForever(
            SKAction.sequence([fadein, delay, fadeout, delay]))
        nextButton_.alpha = 0.0
        textBox_.addChild(nextButton_)

        // キャラクター画像表示
        characterIcon_ = SKSpriteNode()
        characterIcon_.texture = SKTexture(imageNamed: "player.png")
        characterIcon_.anchorPoint = CGPointMake(0.0, 0.0)
        characterIcon_.size = CGSizeMake(
            CHAR_ICON_SIZE - ICON_MARGIN * 2,
            boxHeight_ - ICON_MARGIN * 2)
        characterIcon_.zPosition = 20
        characterIcon_.hidden = true
        characterIcon_.color = UIColor.whiteColor()
    }

    func setPosition(position: POSITION) {
        textBox_.position = self.getPosition(position)
    }

    private func getPosition(position: POSITION) -> CGPoint {
        switch position {
            case .top:
                return CGPointMake(frameWidth_ / 2 - boxWidth_ / 2,
                                   frameHeight_ - boxHeight_ - 30)
            case .middle:
                return CGPointMake(frameWidth_ / 2 - boxWidth_ / 2,
                                   frameHeight_ / 2 - boxHeight_ / 2)
            case .bottom:
                return CGPointMake(frameWidth_ / 2 - boxWidth_ / 2,
                                   30)
        }
    }

    // TODO: キャラクター画像と先送りアイコンのセットを切り出す
    // テキストの anchor point が左上ではなくて真上なので FONT_SIZE/2 を足す
    private func getTalkRegionPosition(position: TALK_SIDE) -> CGPoint {
        switch position {
            case .right:
                textRegionWidth_ = frameWidth_ - PADDING_WIDTH * 2 - CHAR_ICON_SIZE
                rowNum_ = ceil(textRegionWidth_ / charRegionWidth_)
                textRegionWidth_ = rowNum_ * charRegionWidth_
                nextButton_.position = CGPointMake(frameWidth_ - PADDING_WIDTH * 3 / 2,
                                                   PADDING_HEIGHT)
                characterIcon_.position = CGPointMake(ICON_MARGIN,
                                                      PADDING_HEIGHT + FONT_SIZE + ICON_MARGIN)
                characterIcon_.hidden = false
                return CGPointMake(FONT_SIZE / 2 + frameWidth_ - PADDING_WIDTH - textRegionWidth_,
                                   boxHeight_ - FONT_SIZE - PADDING_HEIGHT)
            case .left:
                textRegionWidth_ = frameWidth_ - PADDING_WIDTH - CHAR_ICON_SIZE
                rowNum_ = ceil(textRegionWidth_ / charRegionWidth_)
                textRegionWidth_ = rowNum_ * charRegionWidth_
                nextButton_.position = CGPointMake(frameWidth_ - CHAR_ICON_SIZE - PADDING_WIDTH * 3 / 2,
                                                   PADDING_HEIGHT)
                characterIcon_.position = CGPointMake(textRegionWidth_ + PADDING_WIDTH + ICON_MARGIN,
                                                      PADDING_HEIGHT + FONT_SIZE + ICON_MARGIN)
                characterIcon_.hidden = false
                return CGPointMake(FONT_SIZE / 2 + PADDING_WIDTH,
                                   boxHeight_ - FONT_SIZE - PADDING_HEIGHT)
            case .middle:
                textRegionWidth_ = frameWidth_ - PADDING_WIDTH * 2
                rowNum_ = ceil(textRegionWidth_ / charRegionWidth_)
                textRegionWidth_ = rowNum_ * charRegionWidth_
                nextButton_.position = CGPointMake(frameWidth_ - PADDING_WIDTH * 3 / 2,
                                                   PADDING_HEIGHT)
                characterIcon_.hidden = true
                return CGPointMake(FONT_SIZE / 2 + PADDING_WIDTH,
                                   boxHeight_ - FONT_SIZE - PADDING_HEIGHT)
        }
    }

    func addTo(scene: SKScene) {
        scene.addChild(textBox_)
        scene.addChild(characterIcon_)
    }

    func hide() {
        textBox_.hidden = true
        characterIcon_.hidden = true
    }

    func show(position: POSITION? = nil) {
        self.setPosition(position!)
        textBox_.hidden = false
        characterIcon_.hidden = false
    }

    // 通常の表示
    func drawText(text: String, talkSide: TALK_SIDE) {
        var iDrawingFont: CGFloat = 0     // 描画位置を決める
        var nDrawingFont: CGFloat = 0     // 描画している文字が何番目か決める

        // 先送りボタン非表示
        nextButton_.removeAllActions()
        nextButton_.alpha = 0.0
        // 既に表示されている文字クリア
        clearText()

        for character in text.characters {
            // テキスト描画領域内のanchorpoint
            // 左上から描画する
            let anchor = getTalkRegionPosition(talkSide)

            // 改行文字の判定
            if character == "嬲" {
                iDrawingFont = ceil(iDrawingFont / rowNum_) * rowNum_
                continue
            }

            // 何行目の何文字目を描画するか(0〜)
            var nLine = floor(iDrawingFont / rowNum_)
            var nChar = floor(iDrawingFont % rowNum_)

            if iDrawingFont / rowNum_ + 1 > colNum_ {
                // 行数が超えていたら次ページ
                // TODO: 一行ずつ文字送りするなど，もっと良いやり方がありそう
                textBox_.enumerateChildNodesWithName("text", usingBlock: {
                    node, sotp in

                    let delay = SKAction.waitForDuration(
                    NSTimeInterval(self.VIEW_TEXT_TIME * nDrawingFont)
                    )
                    let fadeout = SKAction.fadeAlphaTo(0.0, duration: 0.0)
                    let seq = SKAction.sequence([delay, fadeout])
                    node.runAction(seq)
                })
                nDrawingFont += 1
                iDrawingFont = 0
                nLine = 0
                nChar = 0
            }

            let char = SKLabelNode(text: String(character))
            char.fontSize = FONT_SIZE
            char.name = "text"
            char.position = CGPointMake(anchor.x + nChar * charRegionWidth_,
                                        anchor.y - nLine * charRegionHeight_)
            char.alpha = 0.0
            textBox_.addChild(char)

            let delay = SKAction.waitForDuration(NSTimeInterval(VIEW_TEXT_TIME * nDrawingFont))
            let fadein = SKAction.fadeAlphaBy(1.0, duration: 0.0)
            let seq = SKAction.sequence([delay, fadein])
            char.runAction(seq)

            iDrawingFont += 1
            nDrawingFont += 1
        }

        // 先送りボタン表示
        let delay = SKAction.waitForDuration(NSTimeInterval(VIEW_TEXT_TIME * nDrawingFont))
        nextButton_.runAction(SKAction.sequence([delay, buttonLoop_]))
    }

    func clearText() {
        var allNode: [SKNode] = []
        textBox_.enumerateChildNodesWithName("text",
                                             usingBlock: {
                                                 node, sotp in allNode.append(node)
                                             })
        textBox_.removeChildrenInArray(allNode)
    }
}