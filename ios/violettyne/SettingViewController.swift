import UIKit

class SettingViewController: UITableViewController {
    let profileImageEdgeLength = 40

    var profileImageView: UIImageView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Photo"
        case 1:
            return "Nickname"
        default:
            return "Preferred Languages"
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0, 1:
            return 1
        default:
            return NSLocale.preferredLanguages().count + 1
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        
        switch indexPath.section {
        case 0:
            cell = tableView.dequeueReusableCellWithIdentifier("profileImageCell", forIndexPath: indexPath) as! UITableViewCell
        case 1:
            cell = tableView.dequeueReusableCellWithIdentifier("nicknameCell", forIndexPath: indexPath) as! UITableViewCell
            for obj in cell.contentView.subviews {
                if let textField = obj as? UITextField {
                    textField.delegate = self
                    let myself = PersistentStorage.getMyself()
                    if let name = myself.name {
                        if !name.isEmpty {
                            textField.text = name
                        }
                    }
                }
            }
        default:
            if indexPath.row == NSLocale.preferredLanguages().count {
                cell = tableView.dequeueReusableCellWithIdentifier("languageFootnoteCell", forIndexPath: indexPath) as! UITableViewCell
            } else {
                let languageCode = (NSLocale.preferredLanguages() as! [String])[indexPath.row]
                let locale = NSLocale(localeIdentifier: languageCode)
                cell = tableView.dequeueReusableCellWithIdentifier("selectedLanguageCell", forIndexPath: indexPath) as! UITableViewCell
                cell.textLabel?.text = locale.displayNameForKey(NSLocaleLanguageCode, value: languageCode)
            }
        }
        
        return cell
    }
}

extension SettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBAction func profileImageDidGetTapped(sender: UITapGestureRecognizer) {
        if let imageView = sender.view as? UIImageView {
            self.profileImageView = imageView
        }
        let controller = UIImagePickerController()
        controller.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        controller.delegate = self
        presentViewController(controller, animated: true) {}
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            if let image = thumbnailSquare(pickedImage, edgeLength: profileImageEdgeLength) {
                self.profileImageView?.image = image
                PersistentStorage.setMyImage(image)
            }
        }
        
        picker.dismissViewControllerAnimated(true) {}
    }
    
    private func thumbnailSquare(image: UIImage, edgeLength: Int) -> UIImage? {
        return resize(cropSquare(image), edgeLength: edgeLength)
    }
    
    private func cropSquare(image: UIImage) -> UIImage? {
        var x, y: CGFloat
        var width, height: CGFloat
        if image.size.width > image.size.height {
            x = (image.size.width - image.size.height) / 2
            y = 0
            width = image.size.height
            height = width
        } else {
            x = 0
            y = (image.size.height - image.size.width) / 2
            height = image.size.width
            width = height
        }
        return UIImage(CGImage: CGImageCreateWithImageInRect(image.CGImage, CGRectMake(x, y, width, height)))
    }
    
    private func resize(image: UIImage?, edgeLength: Int) -> UIImage? {
        let size = CGSize(width: edgeLength, height: edgeLength)
        UIGraphicsBeginImageContext(size)
        image?.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
}

extension SettingViewController: UITextFieldDelegate {
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func nicknameEditingDidEnd(sender: UITextField) {
        PersistentStorage.setMyName(sender.text)
    }
}
