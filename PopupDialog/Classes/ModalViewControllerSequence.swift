import UIKit

public protocol ModalViewControllerSequenceDelegate: class {
    func readyToDismiss(modalViewController: UIViewController, completion: (() -> Void)?)
}

public protocol SequenceableModalViewController {
    var sequenceDelegate: ModalViewControllerSequenceDelegate? { get set }
}
