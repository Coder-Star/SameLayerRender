//
//  SameLayerRenderWebView.swift
//  SameLayerRender
//
//  Created by CoderStar on 2021/7/8.
//

import Foundation
import WebKit

class SameLayerRenderWebView: WKWebView {
    private var isDidHandleWKContentGestrues = false

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        var hitView = super.hitTest(point, with: event)

//        if !isDidHandleWKContentGestrues {
//            handleWKContentGestrues()
//            isDidHandleWKContentGestrues.toggle()
//        }

        /// 处理WKChildScrollView上手势不响应问题
        if let typeClass = NSClassFromString("WKChildScrollView"), let tempHitView = hitView, tempHitView.isKind(of: typeClass) {
            for item in tempHitView.subviews.reversed() {
                let convertPoint = item.convert(point, from: self)
                if let hitTestView = item.hitTest(convertPoint, with: event) {
                    hitView = hitTestView
                    break
                }
            }
        }

        return hitView
    }

    private func handleWKContentGestrues() {
        if let typeClass = NSClassFromString("WKScrollView"), scrollView.isKind(of: typeClass) {
            guard let contentView = scrollView.subviews.first, let gestureRecognizers = contentView.gestureRecognizers else {
                return
            }
            for item in gestureRecognizers {
                item.cancelsTouchesInView = false
                item.delaysTouchesBegan = false
                item.delaysTouchesEnded = false
            }
        }
    }
}
