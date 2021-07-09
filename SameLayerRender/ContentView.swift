//
//  ContentView.swift
//  SameLayerRender
//
//  Created by CoderStar on 2021/7/8.
//

import SwiftUI

struct ContentView: View {
    @State
    private var list = [
        "普通",
        "同层渲染",
    ]

    var body: some View {
        return NavigationView { 
            List {
                ForEach(list, id: \.self) { str in
                    NavigationLink(
                        destination: DemoViewController(title: str).navigationBarTitle(str, displayMode: .inline),
                        label: {
                            Text(str)
                        })
                }
            }.navigationBarTitle("首页", displayMode: .inline)
        }
    }
}

struct DemoViewController: UIViewControllerRepresentable {

    var title: String

    func makeUIViewController(context: UIViewControllerRepresentableContext<DemoViewController>) -> UIViewController {
        let viewController = SameLayerRenderViewController()
        viewController.title = title
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: UIViewControllerRepresentableContext<DemoViewController>) {}
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
