//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import UIKit
import SwiftUI
import EmarsysSDK

struct PullToRefreshView<Manager>: UIViewRepresentable where Manager: MessageManager {
    
    var width : CGFloat
    var height : CGFloat
    
    let manager : Manager
    
    func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.refreshControl = UIRefreshControl()
        scrollView.refreshControl?.addTarget(context.coordinator, action: #selector(Coordinator.handleRefreshControl(sender:)), for: .valueChanged )
        
        let refreshViewController = UIHostingController(rootView: MessagesView(manager: manager))
        refreshViewController.view.frame = CGRect(x: 0, y: 0, width: width, height: height)
        
        scrollView.addSubview(refreshViewController.view)
        
        return scrollView
    }
    
    func updateUIView(_ uiView: UIScrollView, context: Context) {
    
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(pullToRefreshView: self, manager: manager)
    }
    
    class Coordinator: NSObject {
        var pullToRefreshView: PullToRefreshView
        var manager: Manager
        
        init(pullToRefreshView: PullToRefreshView, manager: Manager) {
            self.pullToRefreshView = pullToRefreshView
            self.manager = manager
        }
        
        @objc func handleRefreshControl(sender: UIRefreshControl) {
            sender.endRefreshing()
            manager.fetchMessages()
        }
    }
}
