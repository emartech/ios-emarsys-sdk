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
    var selectedMessage: EMSMessage?
    var dateFormatter: DateFormatter = DateFormatter()
    
    //MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = NSAttributedString.init(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(refresh(refreshControl:)), for: .valueChanged)

        self.tableView.addSubview(refreshControl)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as UITableViewCell
        
        let message = messages[indexPath.row]
        
        cell.textLabel?.text = message.title
        cell.detailTextLabel?.numberOfLines = 5

        let date = Date(timeIntervalSince1970: Double(message.receivedAt.int64Value))
        
        let detailText = "\(message.body) \n \(dateFormatter.string(from: date))"

        if let tags = message.tags {
            let tagsText = tags.reduce("") { $0 == "" ? $1 : "\($0), \($1)"}
            cell.detailTextLabel?.text = "\(detailText) \n TAGS: \(tagsText)"
        } else {
            cell.detailTextLabel?.text = detailText
        }
        
        cell.imageView?.image = #imageLiteral(resourceName: "placeholder")

        guard let imageUrlString = message.imageUrl  else {
            return cell
        }

        guard let imageUrl = URL(string: imageUrlString) else {
            return cell
        }

        guard let imageData = try? Data(contentsOf: imageUrl) else {
          return cell
        }
        
        cell.imageView?.image = UIImage(data: imageData)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.selectedMessage = messages[indexPath.row]
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
        guard let message = selectedMessage else {
            return
        }
        Emarsys.messageInbox.addTag(self.tfTag.text!, forMessage: message.id)
        refresh(refreshControl: nil)
    }
    
    @IBAction func removeTagButtonClicked(_ sender: Any) {
        guard let message = selectedMessage else {
            return
        }
        Emarsys.messageInbox.removeTag(self.tfTag.text!, fromMessage: message.id)
        refresh(refreshControl: nil)
    }
    
}
