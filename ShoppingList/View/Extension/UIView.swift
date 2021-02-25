//
//  UIView.swift
//  ShoppingList
//
//  Created by Alexander Sokhin on 20.02.2021.
//

import UIKit

extension UIView {
 
    func anchor(
        top: NSLayoutYAxisAnchor?,
        left: NSLayoutXAxisAnchor?,
        bottom: NSLayoutYAxisAnchor?,
        right: NSLayoutXAxisAnchor?,
        padding: UIEdgeInsets = .zero,
        width: CGFloat,
        height: CGFloat,
        enableInsets: Bool
    ) {
        
        let insets = self.safeAreaInsets
        var topInset = insets.top
        var bottomInset = insets.bottom
        
        if !enableInsets {
            topInset = 0
            bottomInset = 0
        }
 
        translatesAutoresizingMaskIntoConstraints = false
         
        if let top = top {
            self.topAnchor.constraint(equalTo: top, constant: padding.top + topInset).isActive = true
        }
        if let left = left {
            self.leftAnchor.constraint(equalTo: left, constant: padding.left).isActive = true
        }
        if let right = right {
            rightAnchor.constraint(equalTo: right, constant: -padding.right).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom - bottomInset).isActive = true
        }
        if height != 0 {
            heightAnchor.constraint(equalToConstant: height).isActive = true
        }
        if width != 0 {
            widthAnchor.constraint(equalToConstant: width).isActive = true
        }
    }
    
    func anchor(
        top: NSLayoutYAxisAnchor?,
        bottom: NSLayoutYAxisAnchor?,
        leading: NSLayoutXAxisAnchor?,
        trailing: NSLayoutXAxisAnchor?,
        padding: UIEdgeInsets = .zero,
        enableInsets: Bool = true
    ) {
        
        let insets = self.safeAreaInsets
        var topInset = insets.top
        var bottomInset = insets.bottom
        
        if !enableInsets {
            topInset = 0
            bottomInset = 0
        }
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let top = top {
            topAnchor.constraint(equalTo: top, constant: padding.top + topInset).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: bottom, constant: -padding.bottom - bottomInset).isActive = true
        }
        if let leading = leading {
            leadingAnchor.constraint(equalTo: leading, constant: padding.left).isActive = true
        }
        if let trailing = trailing {
            trailingAnchor.constraint(equalTo: trailing, constant: -padding.right).isActive = true
        }
    }
    
    func anchorHorizontally(to view: UIView) {
      
      translatesAutoresizingMaskIntoConstraints = false
      
      self.leadingAnchor.constraint(
        equalTo: view.leadingAnchor)
        .isActive = true
      
      self.trailingAnchor.constraint(
        equalTo: view.trailingAnchor)
        .isActive = true
    }
    
    func fillSuperview(padding: UIEdgeInsets = .zero) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        if let superviewTopAnchor = superview?.topAnchor {
            topAnchor.constraint(equalTo: superviewTopAnchor, constant: padding.top).isActive = true
        }
        
        if let superviewBottomAnchor = superview?.bottomAnchor {
            bottomAnchor.constraint(equalTo: superviewBottomAnchor, constant: -padding.bottom).isActive = true
        }
        
        if let superviewLeadingAnchor = superview?.leadingAnchor {
            leadingAnchor.constraint(equalTo: superviewLeadingAnchor, constant: padding.left).isActive = true
        }
        
        if let superviewTrailingAnchor = superview?.trailingAnchor {
            trailingAnchor.constraint(equalTo: superviewTrailingAnchor, constant: -padding.right).isActive = true
        }
    }
    
    func centerIn(_ view: UIView, size: CGSize = .zero, xConstant: CGFloat = 0, yConstant: CGFloat = 0) {
        
        translatesAutoresizingMaskIntoConstraints = false
        
        centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: xConstant).isActive = true
        centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: yConstant).isActive = true
        
        if size.width != 0 {
            widthAnchor.constraint(equalToConstant: size.width).isActive = true
        }
        
        if size.height != 0 {
            heightAnchor.constraint(equalToConstant: size.height).isActive = true
        }
    }
    
    func centerByX(_ anchor: NSLayoutXAxisAnchor, constant: CGFloat = 0) {
        centerXAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
    }
    
    func centerByY(_ anchor: NSLayoutYAxisAnchor, constant: CGFloat = 0) {
        centerYAnchor.constraint(equalTo: anchor, constant: constant).isActive = true
    }
}
