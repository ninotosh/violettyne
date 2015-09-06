import UIKit

class MessageReceiver {
    static var messageTableViewController: MessageTableViewController?
    
    class func set(messageTableViewController viewController: MessageTableViewController?) {
        messageTableViewController = viewController
    }
    
    class func receiveMessage(userID: String, text: String) {
        var neighbor: User
        var messages: [Message]

        if userID == messageTableViewController?.neighbor.id {
            let controller = messageTableViewController!

            let indexPath = NSIndexPath(forRow: controller.messages.count, inSection: 0)
            // message must be appended before insertRowsAtIndexPaths()
            controller.messages.append(Message(user: controller.neighbor, text: text))
            controller.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)

            neighbor = controller.neighbor
            messages = controller.messages
        } else {
            neighbor = User(id: userID)
            messages = PersistentStorage.getMessages(neighbor)
            messages.append(Message(user: neighbor, text: text))
        }
        
        PersistentStorage.setMessages(neighbor, messages: messages)
    }
}

class MessageTableViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    
    var neighbor: User!
    var messages: [Message] = []
    
    @IBAction func didTap(sender: UITapGestureRecognizer) {
        textField.resignFirstResponder()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = neighbor.name
        messages = PersistentStorage.getMessages(neighbor)
        
        textField.delegate = self
        
        MessageReceiver.set(messageTableViewController: self)
    }
    
    // UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let indexPath = NSIndexPath(forRow: messages.count, inSection: 0)
        let myself = PersistentStorage.getMyself()
        let message = Message(user: myself, text: textField.text)
        messages.append(message)
        Socket.sendMessage(neighbor, message: message)
        PersistentStorage.setMessages(neighbor, messages: messages)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Bottom)
        textField.text = ""
        return false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! UITableViewCell

        let message = messages[indexPath.row]
        let myself = PersistentStorage.getMyself()

        if message.user.id == myself.id {
            cell.textLabel?.textAlignment = NSTextAlignment.Right
            cell.accessoryView = UIImageView(image: myself.image)
        } else {
            cell.textLabel?.textAlignment = NSTextAlignment.Left
            cell.imageView?.image = message.user.image
        }
        
        cell.textLabel?.text = message.text
        // set the mode programatically because the story board does not show the label
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.lineBreakMode = NSLineBreakMode.ByWordWrapping
        
        return cell
    }
}
