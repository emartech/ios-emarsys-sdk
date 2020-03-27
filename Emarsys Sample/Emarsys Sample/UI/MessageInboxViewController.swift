//
//  Copyright © 2020. Emarsys. All rights reserved.
//

import Foundation
import UIKit
import EmarsysSDK

class MessageInboxViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tfTag: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Variables
    var messages: [EMSMessage] = []
    
    //MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString.init(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(refreshControl:)), for: .valueChanged)

        self.tableView.addSubview(refreshControl)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as UITableViewCell
        
        let message = messages[indexPath.row]
        
        cell.textLabel?.text = message.title
        cell.detailTextLabel?.numberOfLines = 2

        cell.detailTextLabel?.text = "\(message.body)\nReceived at \(Date(timeIntervalSince1970: message.receivedAt.doubleValue / 1000.0))"
        
        cell.imageView?.image = #imageLiteral(resourceName: "placeholder")
        
    
//        guard let imageUrlString = message.imageUrl as? String  else {
//            return cell
//        }
//        
//        guard let imageUrl = URL(string: imageUrlString) else {
//            return cell
//        }
//        
//        URLSession.shared.dataTask(with: imageUrl) { (data, response, error) in
//            DispatchQueue.main.async {
//                cell.imageView?.image = data != nil ? UIImage(data: data!) : #imageLiteral(resourceName: "placeholder")
//            }
//        }.resume()
//        
        return cell
    }
    
    @objc public func refresh(refreshControl: UIRefreshControl?) {
        Emarsys.messageInbox.fetchMessages { result, error in
            if let error = error {
                print("\(error.localizedDescription)")
                let alert = UIAlertController(title: "Error", message: "Please login before fetching inbox", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { action in
                    refreshControl?.endRefreshing()
                }))
                self.present(alert, animated: true, completion: nil)
            } else if let result = result {
                self.messages = result.messages
                self.tableView?.reloadData()
                refreshControl?.endRefreshing()
            }
        }
    }
    
    @IBAction func editButtonClicked(_ sender: Any) {
        self.tableView.setEditing(!self.tableView.isEditing, animated: true)
    }
    
    @IBAction func addTagButtonClicked(_ sender: Any) {
    }
    
    @IBAction func removeTagButtonClicked(_ sender: Any) {
    }
    
}
