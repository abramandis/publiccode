//
//  FirstRunPageVC.swift
//  The Tomorrow Planner
//
//  Created by ABRAM ANDIS on 8/15/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import UIKit

// MARK: --> Protocol for the Delegate

protocol FirstRunPageVCDelegate: class {
    
    func firstRunPageVC(firstRunPageVC: FirstRunPageVC,
                      didUpdatePageCount count: Int)
    
    func firstRunPageVC(firstRunPageVC: FirstRunPageVC,
                      didUpdatePageIndex index: Int)
    
}

// MARK: --> FuturePageVC Subclass

class FirstRunPageVC: UIPageViewController {

    weak var firstRunPageDelegate: FirstRunPageVCDelegate?
    let storyBoardID : String = "FirstLaunchVC"
    let storyBoardIDMainMenu : String = "MainMenuNavController"
    var mainMenu = UIStoryboard(name: "Main", bundle: nil) .
    instantiateViewController(withIdentifier: "MainMenuNavController")
    
   
    private(set) lazy var orderedViewControllers: [FirstRunVC] = {
        // The view controllers will be shown in this order
        var newArray : [FirstRunVC] = []
        
        // setup new View Controllers here
        var newVC = self.newVCFromStoryboard(storyboardID: storyBoardID)
        newArray.append(newVC)
        var secondNewVC = self.newVCFromStoryboard(storyboardID: storyBoardID)
        newArray.append(secondNewVC)
        var thirdNewVC = self.newVCFromStoryboard(storyboardID: storyBoardID)
        newArray.append(thirdNewVC)
      
        return newArray
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        firstRunPageDelegate = self
        
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(viewController: initialViewController)
        }
        
        firstRunPageDelegate?.firstRunPageVC(firstRunPageVC: self, didUpdatePageCount: orderedViewControllers.count)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.setNeedsLayout()
        // not first run
        if !UserDefaults.standard.bool(forKey: UserDefaultsKeys.appFirstRun){
            present(self.mainMenu, animated: false, completion: nil)
        }
    }
    
    private func newVCFromStoryboard(storyboardID: String) -> FirstRunVC {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: storyboardID) as! FirstRunVC
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
        if let firstViewController = viewControllers?.first as? FirstRunVC,
            let index = orderedViewControllers.firstIndex(of: firstViewController) {
            
            firstRunPageDelegate?.firstRunPageVC(firstRunPageVC: self,
                                                         didUpdatePageIndex: index)
            
        }
    }
    
}

// MARK: UIPageViewControllerDataSource

extension FirstRunPageVC: UIPageViewControllerDataSource {
    
    // viewControllerBefore implementation
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let newViewController = viewController as? FirstRunVC,
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
        guard let newViewController = viewController as? FirstRunVC,
            let viewControllerIndex = orderedViewControllers.firstIndex(of: newViewController) else {
                return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // User is on the last view controller and swiped right to loop to
        // the first view controller.
        guard orderedViewControllersCount != nextIndex else {
            //return orderedViewControllers.first
            //self.navigationController?.popViewController(animated: true)
            print("On the last page... tyrin go dismiss")
            //let presentingView = self.presentingViewController as! MainScreenTableViewController
            //presentingView.dismissFirstRunViews()
            
            if UserDefaults.standard.bool(forKey: UserDefaultsKeys.appFirstRun){
                UserDefaults.standard.set(false, forKey: UserDefaultsKeys.appFirstRun)
                //present(self.mainMenu, animated: true, completion: nil)
                self.performSegue(withIdentifier: "MainMenuSegue", sender: self)
            }
            return nil
        }
        
        guard orderedViewControllersCount > nextIndex else {
            return nil
        }
        
        return orderedViewControllers[nextIndex]
    }
    
}

// MARK: --> UIPageViewControllerDelegate

extension FirstRunPageVC: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
    }
    
}

extension FirstRunPageVC: FirstRunPageVCDelegate {
    
    // page count changed
    func firstRunPageVC(firstRunPageVC: FirstRunPageVC,
                      didUpdatePageCount count: Int) {
    }
    
    // page changed
    func firstRunPageVC(firstRunPageVC: FirstRunPageVC,
                      didUpdatePageIndex index: Int) {
        self.view.setNeedsDisplay()

    }
    
}
