//
//  TomorrowPageVC.swift
//  The Tomorrow Planner
//
//  Created by Abram Andis on 7/8/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//

import UIKit

// MARK: --> Protocol for the Delegate

protocol TomorrowPageVCDelegate: class {
    
    func tomorrowPageVC(tomorrowPageVC: TomorrowPageVC,
                      didUpdatePageCount count: Int)
    
    func tomorrowPageVC(tomorrowPageVC: TomorrowPageVC,
                      didUpdatePageIndex index: Int)
    
}

protocol TomorrowNavItemDelegate: class {
    func toggleKeyboardIsDisplayed()
}

class TomorrowPageVC: UIPageViewController, TomorrowNavItemDelegate {
    
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBAction func barButtonPressed(_ sender: Any) {
        if self.editingText {
            print("BOOM")
            self.view.endEditing(true)
        } else {
            print("TESTING TINGINTINGINGINIG")
            self.performSegue(withIdentifier: "NotepadSegue", sender: self)
        }
    }
    
    var dataSourceNotes : String?
    weak var tomorrowPageDelegate: TomorrowPageVCDelegate?
    let storyBoardID : String = "TomorrowStacker"
    let pageTitles : [String] = TomorrowTitleKeys.indexedArrayOfNameKeys
    var currentVCIndex : Int? = nil {
        didSet {
            if currentVCIndex != nil {
                dataSourceNotes = TPTomorrowClass.sharedInstance.tomorrowModel.dataArray[currentVCIndex!].notes
            }
        }
        
    }
    var tapCount : Int = 0
    var editingText : Bool = false {
        didSet {
            if editingText {
                barButton.title = "Done"
            } else {
                barButton.title = "Notepad"
            }
        }
    }

    private(set) lazy var orderedViewControllers: [TomorrowPlanVC] = {
        // The view controllers will be shown in this order
        var newArray : [TomorrowPlanVC] = []
        for (index, object) in TPTomorrowClass.sharedInstance.tomorrowModel.dataArray.enumerated() {
            var newVC = self.newVCFromStoryboard(storyboardID: storyBoardID)
            newVC.mainTitle = object.title
            newVC.modelObjectArray = object.dataArray
            // sets the index of the new vc so it can identify it's place in the Models hierarchy
            // better way?
            newVC.mainIndex = index
            newVC.pageDelegate = self 
            newArray.append(newVC)
        }
        return newArray
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        tomorrowPageDelegate = self
        self.navigationController?.navigationBar.barTintColor = globalUILightGray
        
        self.barButton.title = "Notepad"
      
        
        if let initialViewController = orderedViewControllers.first {
            scrollToViewController(viewController: initialViewController)
        }
        tomorrowPageDelegate?.tomorrowPageVC(tomorrowPageVC: self, didUpdatePageCount: orderedViewControllers.count)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.setNeedsLayout()
    }
    
    private func newVCFromStoryboard(storyboardID: String) -> TomorrowPlanVC {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: storyboardID) as! TomorrowPlanVC
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
        if let firstViewController = viewControllers?.first as? TomorrowPlanVC,
            let index = orderedViewControllers.firstIndex(of: firstViewController) {
            
            tomorrowPageDelegate?.tomorrowPageVC(tomorrowPageVC: self,
                                             didUpdatePageIndex: index)
            
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "NotepadSegue" {
            if let newNotepadVC = segue.destination as? NotepadVC {
                newNotepadVC.dataSourceType = .tomorrow
                newNotepadVC.dataSourceIndex = self.currentVCIndex
                newNotepadVC.dataSourceNotes = self.dataSourceNotes
            } else {
                print("Cannot set data source index for NotepadVC.")
                fatalError()
            }
        }
    }
    
    // NAV ITEM DELEGATE
    func toggleKeyboardIsDisplayed() {
        print("TOGGLE KEYBOARD CALLED!!!")
        editingText.toggle()
    }
}

// MARK: UIPageViewControllerDataSource

extension TomorrowPageVC: UIPageViewControllerDataSource {
    
    // viewControllerBefore implementation
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let newViewController = viewController as? TomorrowPlanVC,
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
        guard let newViewController = viewController as? TomorrowPlanVC,
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

extension TomorrowPageVC: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        notifyTutorialDelegateOfNewIndex()
    }
    
    
}

extension TomorrowPageVC: TomorrowPageVCDelegate {
    
    // page count changed
    func tomorrowPageVC(tomorrowPageVC: TomorrowPageVC,
                      didUpdatePageCount count: Int) {
    }
    
    // page changed
    func tomorrowPageVC(tomorrowPageVC: TomorrowPageVC,
                      didUpdatePageIndex index: Int) {
        // gets the main page title from the VC.pageTitles array 
        self.title = tomorrowPageVC.pageTitles[index]
        self.currentVCIndex = index
    }
    
}
