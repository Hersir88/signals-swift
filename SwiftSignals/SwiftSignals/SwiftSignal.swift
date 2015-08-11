//
//  SwiftSignal.swift
//  SwiftSignals
//
//  Created by Uldis Baurovskis on 07/08/15.
//  Copyright (c) 2015 Uldis Baurovskis. All rights reserved.
//

public class SwiftSignal<T:Comparable>
{
    private var listeners = [SignalTarget<T>]();
    
    public init ()
    {
        
    }
    
    public func dispatch(event:T,sender:AnyObject,data:[AnyObject]?)->SwiftSignal
    {
        var listener:SignalTarget<T>
        var toRemove:[Int] = [Int]()
        
        for var index = 0; index < listeners.count; index++
        {
            listener = listeners[index]
            
            if listener.target == nil {
                toRemove.append(index)
            }
            
            else if listener.hasEvent(event)
            {
                listener.callback(event: event,sender: sender,data: data)
                if listener.once
                {
                    toRemove.append(index)
                }
                
            }
        }
        
        for var index = toRemove.count-1; index >= 0; index--
        {
            listener = listeners[toRemove[index]]
            listener.destroy()
            listeners.removeAtIndex(toRemove[index])
        }
        
        return self;
    }
    
    public func add(events:[T],target:AnyObject,callback:(event:T,sender:AnyObject,data:[AnyObject]?)->Void)->SwiftSignal<T>
    {
        self.registerEvents(events,target: target,callback: callback,once: false);
        return self;
    }
    
    public func addOnce(events:[T],target:AnyObject,callback:(event:T,sender:AnyObject,data:[AnyObject]?)->Void)->SwiftSignal<T>
    {
        self.registerEvents(events,target: target,callback: callback,once: true);
        return self;
    }
    
    public func remove(event:T,target:AnyObject)
    {
        var listener:SignalTarget<T>
        
        for index in reverse(0..<listeners.count)
        {
            listener = listeners[index]
            
            if listener.hasEvent(event) && listener.target === target
            {
                listener.removeEvent(event)
                
                if listener.eventCount == 0
                {
                    listener.destroy()
                    listeners.removeAtIndex(index)
                }
            }
        }
    }
    
    public func removeAll()
    {
        for listener in listeners
        {
            listener.destroy()
        }
        
        listeners.removeAll(keepCapacity: false)
    }
    
    public func destroy()
    {
        removeAll()
    }
    
    private func registerEvents(events:[T],target:AnyObject,callback:(event:T,sender:AnyObject,data:[AnyObject]?)->Void,once:Bool)
    {
        for event in events
        {
            remove(event, target: target)
        }
        
        var item:SignalTarget<T> = SignalTarget<T>(target: target, callback: callback);
        item.once=once;
        
        for event in events
        {
            item.addEvent(event)
        }
        
        listeners.append(item)
    }
}

/**
@discussion Helper class to hold listener
*/

class SignalTarget<T:Comparable>
{
    var events:[T]=[T]()
    var target:AnyObject?
    var callback:(event:T,sender:AnyObject,data:[AnyObject]?)->Void
    var once:Bool=false
    
    var eventCount:Int {
        get {
            return events.count
        }
    }
    
    init(target:AnyObject,callback:(event:T,sender:AnyObject,data:[AnyObject]?)->Void)
    {
        self.target=target
        self.callback=callback
    }
    
    func addEvent(event:T)
    {
        if isUniqueEvent(event)
        {
            events.append(event);
        }
        
    }
    
    func removeEvent(event:T)
    {
        for index in  0...events.count
        {
            if events[index] == event
            {
                events.removeAtIndex(index);
                break;
            }
        }
        
    }
    
    func hasEvent(event:T)->Bool
    {
        return !isUniqueEvent(event)
    }
    
    func destroy()
    {
        events.removeAll(keepCapacity: false)
        self.target = nil
    }
    
    private func isUniqueEvent(event:T)->Bool
    {
        for e in events
        {
            if e == event
            {
                return false;
            }
        }
        
        return true;
    }
}
