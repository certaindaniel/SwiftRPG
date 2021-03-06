//
//  Event.swift
//  SwiftRPG
//
//  Created by tasuku tozawa on 2015/08/12.
//  Copyright © 2015年 兎澤佑. All rights reserved.
//

import Foundation
import SwiftyJSON
import UIKit

protocol NotifiableFromListener {
    func invoke(invoker: EventListener, listener: EventListener)
}

class EventDispatcher : NotifiableFromListener {
    typealias ListenerType = EventListener
    typealias IdType = UInt64

    private var listeners = Dictionary<IdType, ListenerType>()
    private var uniqueId: UInt64 = 0

    var delegate: NotifiableFromDispacher?

    init() {}

    func add(listener: ListenerType) -> Bool {
        if listener.id != nil { return false }
        let id = issueId()
        listener.delegate = self
        listeners[id] = listener
        listener.id = id
        return true
    }

    func remove(listener: ListenerType) -> Bool {
        if listener.id == nil { return false }
        listeners.removeValueForKey(listener.id!)
        listener.id = nil
        return true
    }
    
    func removeAll() {
        listeners.removeAll()
    }

    func trigger(sender: AnyObject!, args: JSON!) throws {
        for listener in listeners.values {
            do {
                try listener.invoke(sender: sender, args: args)
            } catch {
                throw error
            }
        }
    }
    
    func hasListener() -> Bool {
        return self.listeners.count > 0
    }

    private func issueId() -> IdType {
        repeat {
            uniqueId += 1
            if listeners[uniqueId] == nil {
                return uniqueId
            }
        } while (true) // ToDo
    }

    // MARK: NotifilableFromListener

    func invoke(invoker: EventListener, listener nextListener: EventListener) {
        self.delegate?.invoke(invoker, listener: nextListener)
    }
}


