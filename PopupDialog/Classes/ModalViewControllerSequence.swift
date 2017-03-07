import UIKit

/**
    View controllers that need to present a sequence of modal view controllers
    should implement this protocol.

    Normally, modal view controller that is displayed over the presenting view controller
    cannot transition nicely into another modal view controller. One modal view
    controller needs to be dismissed first and then the second one is presented.
    This protocol enables modal view controllers to present one over the other and than
    when the sequence of modal view controllers is over, the last one calls readyToDismiss()
    which collapses the whole sequence.

 */
public protocol ModalViewControllerSequenceDelegate: class {}

// Ideally I would put `where Self: UIViewController` restriction to the extension,
// but Swift currently doesn't support declaring a variable of certain type which also
// implements a certain protocol,
//
// e.g. sequenceDelegate: ModalViewControllerSequenceDelegate & UIViewController
//
// so someone using this extension would need to cast UIViewController into
// ModalViewControllerSequenceDelegate or vice versa all the time. So I'd rather do this
// casting within the extension. It should make the usage of this extension simpler.
public extension ModalViewControllerSequenceDelegate {

    /// Last modal view controller in a sequence calls this method to collapse the sequence.
    ///
    /// - Parameters:
    ///   - modalViewController: modal view controller that calls this method
    ///   - completion: block to be executed after the sequence is collapsed
    func readyToDismiss(modalViewController: UIViewController, completion: (() -> Void)?) {
        guard let selfAsViewController = self as? UIViewController else {
            fatalError("self needs to be an instance of the UIViewController, instead of \(type(of:self)).")
        }
        if let presentingViewController = modalViewController.presentingViewController {
            if presentingViewController == selfAsViewController {
                selfAsViewController.dismiss(animated: true, completion: completion)
            } else {
                presentingViewController.dismiss(animated: true) {
                    selfAsViewController.dismiss(animated: false, completion: completion)
                }
            }
        } else {
            fatalError("modalViewController.presentingViewController is nil, which means that modalViewController isn't presented and cannot be dismissed.")
        }
    }

}

/**
    Modal view controllers that are presented in a sequence should implement this protocol.

    SequenceableModalViewController is responsible of implementing appropriate transitions
    between two instances in the sequence and also the dismissal of the last instance in the
    sequence.

    SequenceableModalViewController is responsible for passing the sequence delegate reference up the stack
    with each new SequenceableModalViewController added so that the last one can call readyToDismiss() on it.
 */
public protocol SequenceableModalViewController {
    weak var sequenceDelegate: ModalViewControllerSequenceDelegate? {get set}
}
