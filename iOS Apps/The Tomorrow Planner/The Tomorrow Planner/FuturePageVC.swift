//
//  FuturePageVC.swift
//  The Tomorrow Planner
//
//  Created by Abram Andis on 7/2/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import UIKit

// MARK: --> Protocol for the Delegate

protocol FuturePageVCDelegate: class {
    
    func futurePageVC(futurePageVC: FuturePageVC,
                      didUpdatePageCount count: Int)
    
    func futurePageVC(futurePageVC: FuturePageVC,
                      didUpdatePageIndex index: Int)
    
}

// MARK: --> FuturePageVC Subclass

class FuturePageVC: UIPageViewController {

    weak var futurePageDelegate: FuturePageVCDelegate?
    let storyBoardID : String = "FutureStacker"
    let pageTitles : [String] = TPFutureClass.sharedInstance.futureModel.titles
    //let localModel = TPFutureClass.sharedInstance.futureModel
    
    // was private(set) lazy var
    private(set) lazy var orderedViewControllers: [FuturePlanVC] = {
        // The view controllers will be shown in this order
        var newArray : [FuturePlanVC] = []
        for (index, object) in TPFutureClass.sharedInstance.futureModel.dataArray.enumerated() {
            var newVC = self.newVCFromStoryboard(storyboardID: storyBoardID)
            newVC.mainTitle = object.mainTitle
            newVC.modelObjectArray = object.dataArray
            // sets the index of the new vc so it can identify it's place in the Models hierarchy
            // better way?
            newVC.mainIndex = index
            newArray.append(newVC)
        }
        return newArray
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        futurePageDelegate = self
        self.navigationController?.navigationBar.barTintColor = globalUILightGray
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(viewController: initialViewController)
        }
        
        futurePageDelegate?.futurePageVC(futurePageVC: self, didUpdatePageCount: orderedViewControllers.count)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.setNeedsLayout()
    }
    
    private func newVCFromStoryboard(storyboardID: String) -> FuturePlanVC {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: storyboardID) as! FuturePlanVC
    }

    // Scrolls to next view controller
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter : visibleViewController) {
            scrollToViewController(viewController: nextViewController)
        }
    }
    
    // Scrolls to specific View Controller
    // parameter: view controller to scroll to
    private func scrollToViewController(viewController: UIViewController) {
        setViewControllers([viewController],
                           direction: .forward,
                           animated: true,
                           completion: { (finished) -> Void in
                            // Setting the view controller programmatically does not fire
                            // any delegate methods, so we have to manually notify the
                            // 'tutorialDelegate' of the new index.
                            self.notifyTutorialDelegateOfNewIndex()
        })
    }
    
    // Notifies delegate the current page index was updated
    private func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first as? FuturePlanVC,
            let index = orderedViewControllers.firstIndex(of: firstViewController) {
            
            futurePageDelegate?.futurePageVC(futurePageVC: self,
                                                         didUpdatePageIndex: index)
            
        }
    }
    
}

// MARK: UIPageViewControllerDataSource

extension FuturePageVC: UIPageViewControllerDataSource {
    
    // viewControllerBefore implementation
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let newViewController = viewController as? FuturePlanVC,
            let viewControllerIndex = orderedViewControllers.firstIndex(of: newViewController) else {
                return nil
        }
        
        let previousIndex = viewControllerIndex - 1
        
        // User is on the first view controller and swiped left to loop to
        // the last view controller.
        guard previousIndex >= 0 else {
            //return orderedViewControllers.last
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        
        return orderedViewControllers[previousIndex]
    }
    
    // viewControllerAfter implementation
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter
        viewController: UIViewController) -> UIViewController? {
        guard let newViewController = viewController as? FuturePlanVC,
            let viewControllerIndex = orderedViewControllers.firstIndex(of: newViewController) else {
                return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            //return orderedViewControllers.first
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}

// MARK: --> UIPageViewControllerDelegate

extension FuturePageVC: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
    }
    
}

extension FuturePageVC: FuturePageVCDelegate {
    
    // page count changed
    func futurePageVC(futurePageVC: FuturePageVC,
                      didUpdatePageCount count: Int) {
    }
    
    // page changed
    func futurePageVC(futurePageVC: FuturePageVC,
                      didUpdatePageIndex index: Int) {
    
        self.title = futurePageVC.pageTitles[index]
        self.view.setNeedsDisplay()

    }
    
}
