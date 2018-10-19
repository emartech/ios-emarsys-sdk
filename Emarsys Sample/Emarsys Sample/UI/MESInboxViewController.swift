//
//  Copyright © 2017. Emarsys. All rights reserved.
//

import Foundation
import UIKit
import EmarsysSDK

class MESInboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //MARK: Outlets
    @IBOutlet weak var notificationTableView: UITableView!

    //MARK: Variables
    var notifications: [EMSNotification] = []

    //MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString.init(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(refreshControl:)), for: .valueChanged)

        self.notificationTableView.addSubview(refreshControl)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        Emarsys.inbox.resetBadgeCount { error in
            if let error = error {
                print(error as Any)
            } else {
                self.tabBarItem.badgeValue = nil
            }
        }
    }

    //MARK: Public methods
    @objc public func refresh(refreshControl: UIRefreshControl?) {
        Emarsys.inbox.fetchNotifications { [unowned self] status, error in
            if let error = error {
                print(error as Any)
                let alert = UIAlertController(title: "Error", message: "Please login before fetching inbox", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                    refreshControl?.endRefreshing()
                }))
                self.present(alert, animated: true, completion: nil)
            } else if let status = status {
                self.notifications = status.notifications
                self.notificationTableView?.reloadData()

                self.tabBarItem.badgeValue = status.badgeCount != 0 ? "\(status.badgeCount)" : nil
                refreshControl?.endRefreshing()
            }
        }
    }

    //MARK: UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as UITableViewCell
        
        let notification = notifications[indexPath.row]
        
        cell.textLabel?.text = notification.title
        cell.detailTextLabel?.numberOfLines = 2

        cell.detailTextLabel?.text = "\(notification.body!)\nReceived at \(Date(timeIntervalSince1970: notification.receivedAtTimestamp.doubleValue))"
        
        cell.imageView?.image = #imageLiteral(resourceName: "placeholder")
        
        guard let imageUrlString = notification.customData["image"]  else {
            return cell
        }
        
        guard let imageUrl = URL(string: imageUrlString) else {
            return cell
        }
        
        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
            DispatchQueue.main.async {
                cell.imageView?.image = data != nil ? UIImage(data: data!) : #imageLiteral(resourceName: "placeholder")
            }
        }.resume()
        
        return cell
    }

}
