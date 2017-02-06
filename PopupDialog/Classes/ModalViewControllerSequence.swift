import UIKit

public protocol ModalViewControllerSequenceDelegate: class {}

// Ideally I would put `where Self: UIViewController` restriction to the extension,
// but Swift currently doesn't support declaring a variable of certain type which also
// implements certain protocol,
// e.g. sequenceDelegate: ModalViewControllerSequenceDelegate & UIViewController
// so someone using this extension would need to cast UIViewController into
// ModalViewControllerSequenceDelegate or vice versa all the time. So I'd rather do this
// casting within the extension. It should make the usage of this extension simpler.
extension ModalViewControllerSequenceDelegate {

    func readyToDismiss(modalViewController: UIViewController, completion: (() -> Void)?) {
        guard let selfAsViewController = self as? UIViewController else {
            fatalError("self needs to be an instance of the UIViewController, instead of \(type(of:self)).")
        }
        if let presentingViewController = modalViewController.presentingViewController {
            if presentingViewController == selfAsViewController {
                selfAsViewController.dismiss(animated: true, completion: completion)
            } else {
                presentingViewController.dismiss(animated: true)
                selfAsViewController.dismiss(animated: false, completion: completion)
            }
        } else {
            fatalError("modalViewController.presentingViewController is nil, which means that it isn't presented and cannot be dismissed.")
        }
    }

}

public protocol SequenceableModalViewController {
    weak var sequenceDelegate: ModalViewControllerSequenceDelegate? {get set}
}
