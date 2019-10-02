//
//  Copyright (c) 2017 Emarsys. All rights reserved.
//

import UIKit
import EmarsysSDK

class MESMobileEngageViewController: UIViewController {

//MARK: Outlets
    @IBOutlet weak var contactFieldValueTextField: UITextField!
    @IBOutlet weak var sidTextField: UITextField!
    @IBOutlet weak var customEventNameTextField: UITextField!
    @IBOutlet weak var customEventAttributesTextView: UITextView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var scrollViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tvInfos: UITextView!

//MARK: Variables
    var pushToken: String?

    func createResponseHandler() -> EMSCompletionBlock {
        return { error in
            if let error = error {
                OperationQueue.main.addOperation({
                    self.tvInfos.text.append("💔 \(error)")
                });
            } else {
                OperationQueue.main.addOperation({
                    self.tvInfos.text.append("💚 OK")
                });
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        NotificationCenter.default.addObserver(forName: NotificationNames.pushTokenArrived.asNotificationName(), object: nil, queue: OperationQueue.main) { [unowned self] (notification: Notification) in
            if let data = notification.userInfo?["push_token"] as? Data {
                self.pushToken = data.map {
                    String(format: "%02.2hhx", $0)
                }.joined()
            }
        }
    }

//MARK: ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        self.view.addGestureRecognizer(tapGestureRecognizer)

        registerForKeyboardNotifications()
    }

//MARK: Actions
    @IBAction func loginButtonClicked(_ sender: Any) {
        guard let valueText = self.contactFieldValueTextField.text else {
            showAlert(with: "Wrong parameter")
            return
        }
        Emarsys.setContactWithContactFieldValue(valueText) { (error) in
            self.createResponseHandler()(error)
            let inboxViewController = self.tabBarController?.viewControllers?[1] as! MESInboxViewController
            inboxViewController.refresh(refreshControl: nil)
        }
        self.tvInfos.text = "Login: "
    }

    @IBAction func trackMessageButtonClicked(_ sender: Any) {
        guard let sid = sidTextField.text else {
            showAlert(with: "Missing sid")
            return
        }
        Emarsys.push.trackMessageOpen(userInfo: ["u": "{\"sid\":\"\(sid)\"}"], completionBlock: createResponseHandler())
        self.tvInfos.text = "Message open: "
    }

    @IBAction func trackCustomEventButtonClicked(_ sender: Any) {
        guard let eventName = self.customEventNameTextField.text, !eventName.isEmpty else {
            showAlert(with: "Missing eventName")
            return
        }
        var eventAttributes: [String: String]?
        if let attributes = self.customEventAttributesTextView.text {
            if let data = attributes.data(using: .utf8) {
                do {
                    eventAttributes = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
                } catch {
                    showAlert(with: "Invalid JSON")
                    print(error.localizedDescription)
                }
            }
        }
        Emarsys.trackCustomEvent(withName: eventName, eventAttributes: eventAttributes, completionBlock: createResponseHandler())
        self.tvInfos.text = "Track custom event: "
    }

    @IBAction func logoutButtonClicked(_ sender: Any) {
        Emarsys.clearContact(completionBlock: createResponseHandler())
        self.tvInfos.text = "App logout: "
    }

    @IBAction func togglePausedValue(_ sender: UISwitch) {
        if sender.isOn {
            Emarsys.inApp.pause()
        } else {
            Emarsys.inApp.resume()
        }
    }

    @IBAction func showPushTokenButtonClicked(_ sender: Any) {
        var message: String = ""
        if (self.pushToken != nil) {
            message = self.pushToken!
        } else {
            message = "No pushtoken"
        }

        showAlert(with: message)
        UIPasteboard.general.string = message
    }

}

extension Array where Element: Equatable {

    mutating func remove(_ element: Element) {
        guard let elementIndex = self.index(where: { $0 == element }) else {
            return
        }
        self.remove(at: elementIndex)
    }
}
