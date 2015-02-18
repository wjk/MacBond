//
//  Bond+AppKit.swift
//  Bond
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Srdan Rasic (@srdanrasic)
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import Foundation
import AppKit

protocol ControlDynamicHelper {
    typealias T
    var value: T { get }
    var listener: (T -> Void)? { get set }
}

class ControlDynamic<T, U: ControlDynamicHelper where U.T == T>: Dynamic<T> {
    var helper: U
    init(helper: U) {
        self.helper = helper
        super.init(helper.value)
        self.helper.listener = {
            [unowned self] in
            self.value = $0
        }
    }
}

@objc private class ButtonDynamicHelper: NSObject, ControlDynamicHelper {
    weak var control: NSButton?
    var value: NSButton?
    var listener: (NSButton? -> Void)?
    
    init(control: NSButton) {
        self.control = control
        super.init()
        
        control.target = self
        control.action = Selector("action:")
    }
    
    @objc(action:) private func action(sender: AnyObject?) {
        if let sender: AnyObject = sender {
            value = sender as? NSButton
        } else {
            value = nil
        }
        
        self.listener?(value)
    }
}

@objc private class TextFieldDynamicHelper: NSObject, ControlDynamicHelper {
    weak var control: NSTextField?
    
    var value: String {
        get {
            return control?.stringValue ?? ""
        }
    }
    
    var listener: (String -> Void)?
    
    init(control: NSTextField) {
        self.control = control
        super.init()
        
        control.target = self
        control.action = Selector("textChanged:")
    }
    
    @objc(textChanged:) private func textChanged(sender: AnyObject?) {
        self.listener?(value)
    }
}

// MARK: -

private var designatedBondHandleNSLabel = 0
private var designatedBondHandleNSProgressIndicator = 0
private var designatedBondHandleNSButton_Enabled = 0, designatedBondHandleNSButton_State = 0, designatedBondHandleNSButton_StringValue = 0

extension NSTextField: Dynamical, Bondable {
    public func designatedDynamic() -> Dynamic<String> {
        return ControlDynamic<String, TextFieldDynamicHelper>(helper: TextFieldDynamicHelper(control: self))
    }
    
    public var designatedBond: Bond<String> {
        if let b: AnyObject = objc_getAssociatedObject(self, &designatedBondHandleNSLabel) {
            return b as! Bond<String>
        } else {
            let b = Bond<String>() {
                [unowned self] v in
                self.stringValue = v
            }
            
            objc_setAssociatedObject(self, &designatedBondHandleNSLabel, b, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
            return b
        }
    }
    
    public var editableBond: Bond<Bool> {
        get {
            if let b: AnyObject = objc_getAssociatedObject(self, &designatedBondHandleNSButton_StringValue) {
                return b as! Bond<Bool>
            } else {
                let b = Bond<Bool>() {
                    [unowned self] v in
                    self.selectable = v
                    self.editable = v
                    self.bezeled = v
                    self.drawsBackground = v
                }
                
                objc_setAssociatedObject(self, &designatedBondHandleNSButton_StringValue, b, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
                return b
            }
        }
    }
}

extension NSProgressIndicator: Bondable {
    public var designatedBond: Bond<Double> {
        if let b: AnyObject = objc_getAssociatedObject(self, &designatedBondHandleNSProgressIndicator) {
            return b as! Bond<Double>
        } else {
            let b = Bond<Double>() {
                [unowned self] v in
                self.doubleValue = v
            }
            
            objc_setAssociatedObject(self, &designatedBondHandleNSProgressIndicator, b, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
            return b
        }
    }
}

extension NSButton: Dynamical {
    public func designatedDynamic() -> Dynamic<NSButton?> {
        return ControlDynamic<NSButton?, ButtonDynamicHelper>(helper: ButtonDynamicHelper(control: self))
    }
    
    public var enabledBond: Bond<Bool> {
        get {
            if let b: AnyObject = objc_getAssociatedObject(self, &designatedBondHandleNSButton_Enabled) {
                return b as! Bond<Bool>
            } else {
                let b = Bond<Bool>() {
                    [unowned self] v in
                    self.enabled = v
                }
                
                objc_setAssociatedObject(self, &designatedBondHandleNSButton_Enabled, b, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
                return b
            }
        }
    }
    
    public var checkedBond: Bond<Bool> {
        get {
            if let b: AnyObject = objc_getAssociatedObject(self, &designatedBondHandleNSButton_State) {
                return b as! Bond<Bool>
            } else {
                let b = Bond<Bool>() {
                    [unowned self] v in
                    self.state = v ? NSOnState : NSOffState
                }
                
                objc_setAssociatedObject(self, &designatedBondHandleNSButton_State, b, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
                return b
            }
        }
    }
    
    public var textBond: Bond<String> {
        get {
            if let b: AnyObject = objc_getAssociatedObject(self, &designatedBondHandleNSButton_StringValue) {
                return b as! Bond<String>
            } else {
                let b = Bond<String>() {
                    [unowned self] v in
                    self.stringValue = v
                }
                
                objc_setAssociatedObject(self, &designatedBondHandleNSButton_StringValue, b, objc_AssociationPolicy(OBJC_ASSOCIATION_RETAIN))
                return b
            }
        }
    }
}
