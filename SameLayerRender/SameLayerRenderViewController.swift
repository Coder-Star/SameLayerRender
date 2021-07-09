//
//  SameLayerRenderViewController.swift
//  SameLayerRender
//
//  Created by CoderStar on 2020/9/7.
//  Copyright © 2020 CoderStar. All rights reserved.
//

import Foundation
import UIKit
import WebKit

/**
   测试同屏渲染相关，大致流程如下
 1、创建一个 DOM 节点并设置其 CSS 属性为 overflow: scroll（低版本需要设置-webkit-overflow-scrolling: touch）； 并且需要在该DOM节点下插入一个高度超过该Dom节点的子节点，才能生成一个WKChildScrollView（重要）；
 2、通知客户端查找到该 DOM 节点对应的原生 WKChildScrollView 组件；
 3、将原生组件挂载到该 WKChildScrollView 节点上作为其子 View。

 同层渲染后，插入的原生组件时无法响应交互事件的，需要特殊进行处理
 */

class SameLayerRenderViewController: UIViewController {
    private var isSameLayerRender = false

    private let messageHandlerHandler = "nativeRender"

    private var nativeRenderViewArr: [UIView] = []

    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.text = ""
        textField.layer.borderColor = UIColor.red.cgColor
        textField.layer.borderWidth = 1
        return textField
    }()

    private lazy var textView: UITextView = {
        let textView = UITextView()
        textView.text = ""
        textView.layer.borderColor = UIColor.red.cgColor
        textView.layer.borderWidth = 1
        return textView
    }()

    private lazy var webView: SameLayerRenderWebView = {
        let webView = SameLayerRenderWebView()
        webView.uiDelegate = self
        webView.navigationDelegate = self
        return webView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let htmlURL = Bundle.main.url(forResource: "SameLayerRender", withExtension: "html") else {
            return
        }
        webView.frame = view.frame
        view.addSubview(webView)
        webView.loadFileURL(htmlURL, allowingReadAccessTo: htmlURL)
        isSameLayerRender = title == "同层渲染"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        webView.configuration.userContentController.add(self, name: messageHandlerHandler)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        webView.configuration.userContentController.removeScriptMessageHandler(forName: messageHandlerHandler)
    }

    deinit {
        print("SameLayerRenderViewController销毁")
    }
}

extension SameLayerRenderViewController: WKNavigationDelegate {}

extension SameLayerRenderViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if !isSameLayerRender {
            return
        }

        guard let dic = message.body as? [String: Any], let index = dic["index"] as? Int, let type = dic["type"] as? String else {
            return
        }

        /**
         下列将Html组件替换成原生组件的方式还有简陋，有很多优化的地方。
         1、组件替换过程中的一闪而过
         */

        if nativeRenderViewArr.isEmpty {
            // 获取所有WKChildScrollView
            for item in webView.getAllSubViews() {
                if let typeClass = NSClassFromString("WKChildScrollView"), item.isKind(of: typeClass) {
                    (item as? UIScrollView)?.isScrollEnabled = false
                    nativeRenderViewArr.append(item)
                }
            }
        }

        if index >= nativeRenderViewArr.count {
            return
        }

        if message.name == messageHandlerHandler {
            switch type {
            case "input":
                nativeRenderViewArr[index].removeAllSubview()
                textField.frame = nativeRenderViewArr[index].bounds
                nativeRenderViewArr[index].addSubview(textField)
            case "textarea":
                nativeRenderViewArr[index].removeAllSubview()
                textView.frame = nativeRenderViewArr[index].frame
                nativeRenderViewArr[index].addSubview(textView)
            default:
                break
            }
        }
    }
}

extension SameLayerRenderViewController: WKUIDelegate {
    public func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let okAciton = UIAlertAction(title: "确定", style: .default) { _ in
            completionHandler()
        }
        alertController.addAction(okAciton)
        if presentedViewController == nil {
            present(alertController, animated: true, completion: nil)
        } else {
            completionHandler()
        }
    }
}

extension UIView {
    private static var allSubviews: [UIView] = []

    // 递归遍历view的所有子孙view，深度优先遍历
    private func viewArray(root: UIView) -> [UIView] {
        for view in root.subviews {
            if view.isKind(of: UIView.self) {
                UIView.allSubviews.append(view)
            }
            _ = viewArray(root: view)
        }
        return UIView.allSubviews
    }

    /// 获取所有子视图
    fileprivate func getAllSubViews() -> [UIView] {
        UIView.allSubviews = []
        return viewArray(root: self)
    }

    /// 移除所有子视图
    fileprivate func removeAllSubview() {
        subviews.forEach {
            $0.removeFromSuperview()
        }
    }
}
