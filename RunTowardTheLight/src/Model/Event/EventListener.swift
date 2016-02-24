//
//  EventListener.swift
//  RunTowardTheLight
//
//  Created by 兎澤佑 on 2015/09/04.
//  Copyright © 2015年 兎澤佑. All rights reserved.
//

import Foundation
import UIKit

class EventListener<EventArgType> {
    typealias EventMethod = (sender:AnyObject!, args:EventArgType!) -> ()
    typealias IdType = UInt64

    /// イベントメソッド
    let invoke: EventMethod!
    
    /// イベントID
    internal var id: IdType?

    ///  コンストラクタ
    ///
    ///  - parameter callback: イベントを実行するコールバック関数
    ///
    ///  - returns:
    init(callback: EventMethod!) {
        self.invoke = callback
        self.id = nil
    }
}