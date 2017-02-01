import UIKit

public protocol ViewControllerFlowDelegate: class {
    func readyToDismiss(viewController: UIViewController, completion: (() -> Void)?)
    //func getNextViewControllerToPresent(currentViewController: UIViewController) -> UIViewController?
}

public protocol ViewControllerFlowable {
    var viewControllerFlowDelegate: ViewControllerFlowDelegate? { get set }
}
