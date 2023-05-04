//
//  UIView+Extension.swift
//  Popovers
//
//  Copyright © 2021 PSPDFKit GmbH. All rights reserved.
//

import UIKit

extension UIView {
    func closestVC() -> UIViewController? {
        var responder: UIResponder? = self
        while responder != nil {
            if let viewCtrl = responder as? UIViewController {
                return viewCtrl
            }
            responder = responder?.next
        }
        return nil
    }
}
