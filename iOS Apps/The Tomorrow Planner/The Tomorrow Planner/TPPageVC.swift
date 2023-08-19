//
//  TPPageVC.swift
//  The Tomorrow Planner
//
//  Created by ABRAM ANDIS on 8/23/19.
//  Copyright © 2019 Small Blue Idea, Inc. All rights reserved.
//


// NOTE: replacing localContainerModelWith
import UIKit

public struct StoryBoardKeys {
    static let notepadSegue = "NotepadSegue"
    static let stackerVC = "StackerVC"
}

public struct NavBarItemTitleKeys {
    static let done = "Done"
    static let notepad = "Notepad"
}

// MARK: - Protocols
protocol TPPageVCDelegate: class {
    func tpPageVC(tpPageVC: TPPageVC,
                      didUpdatePageCount count: Int)
    
    func tpPageVC(tpPageVC: TPPageVC,
                      didUpdatePageIndex index: Int)
}

protocol TPPageVCNavItemDelegate: class {
    func toggleKeyboardIsDisplayed()
}

// MARK: - TPPageVC Class
class TPPageVC: UIPageViewController {
    
    // MARK: - Outlets
    
    @IBOutlet weak var barButton: UIBarButtonItem!
    @IBAction func barButtonPressed(_ sender: Any) {
        if self.editingText {
            self.view.endEditing(true)
        } else {
            self.performSegue(withIdentifier: StoryBoardKeys.notepadSegue, sender: self)
        }
    }
    
    // MARK: - Tap Gesture
    @objc func onTapGesture(touch: UITapGestureRecognizer){
        if touch.state == .ended {
            UIView.animate(withDuration: 0.3) { self.viewOverLay.alpha = 0 }
            UIView.animate(withDuration: 0.3) { self.swipeTutorialView.alpha = 0 }
        }
    }
    
    // MARK: - Variables
    
    lazy var userDefaults: UserDefaults = UserDefaults.standard
    var viewOverLay = UIView()
    var swipeTutorialView = UIView()
    var tapGesture : UITapGestureRecognizer?
    var tapGesture2 : UITapGestureRecognizer?
    
    weak var tpPageDelegate: TPPageVCDelegate?
    var dataSourceType : DataSourceEnum!
    //var localContainer : TPContainerModelX!
    var notesForCurrentVC : String?
    var titleForCurrentVC : String?
    var currentVCIndex : Int = 0 {
        didSet {
            // update notes data source and UI
            //notesForCurrentVC = localContainerModel.planArray[currentVCIndex].notes
            titleForCurrentVC = getModelData(type: dataSourceType).planArray[currentVCIndex].title
            self.title = titleForCurrentVC
        }
    }
    var editingText : Bool = false {
        didSet {
            // update UI nav buttons
            if editingText {
                barButton.title = NavBarItemTitleKeys.done
            } else {
                barButton.title = NavBarItemTitleKeys.notepad
            }
        }
    }
    // creates the view controllers
    private(set) lazy var orderedViewControllers: [TPPlanVC] = {
        // creates an array of instantiated TPPlanVCs
        var newArray : [TPPlanVC] = []
        for (index, plan) in getModelData(type: dataSourceType).planArray.enumerated() {
            let newVC = self.newVCFromStoryboard(storyboardID: StoryBoardKeys.stackerVC)
            newVC.mainTitle = plan.title
            //newVC.localObjectStack = plan.objectStack
            newVC.mainIndex = index
            newVC.dataSourceType = self.dataSourceType
            newVC.pageDelegate = self
            newArray.append(newVC)
        }
        return newArray
    }()
    
    // MARK: - Utilities
    
    private(set) var showSwipeTutorial: Bool {
        get {
            if UserDefaults.standard.bool(forKey: "showSwipeTutorial") {
                return true
            } else {
                return false
            }
        }
        set {
            userDefaults.set(false, forKey: "showSwipeTutorial")
        }
    }
    
    // MARK: - viewDidLoad()
    override func viewDidLoad() {
        super.viewDidLoad()
        guard dataSourceType != nil else { fatalError("no data source type!") }
        //guard localContainer != nil else { fatalError("no model data present!") }
       
        userDefaults.synchronize()
        
        
        // initialize
        dataSource = self
        delegate = self
        tpPageDelegate = self
        self.notesForCurrentVC = getModelData(type: dataSourceType).planArray[currentVCIndex].notes
        self.title = getModelData(type: dataSourceType).planArray[currentVCIndex].title
        self.barButton.title = NavBarItemTitleKeys.notepad
        self.navigationController?.navigationBar.barTintColor = globalUILightGray
        if let initialViewController = orderedViewControllers.first {
         scrollToViewController(viewController: initialViewController)
        }
        tpPageDelegate?.tpPageVC(tpPageVC: self, didUpdatePageCount: orderedViewControllers.count)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.view.setNeedsLayout()
        //self.view.updateConstraintsIfNeeded()
        /// UPDATE LOCAL MODEL STORE
        /// USE AND RESEARCH DEPENDENCY INJECTION
        
        if showSwipeTutorial == true {
            
            // initialize gesture recognizers
            // initialize gesture recognizer
            tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(touch:)))
            tapGesture2 = UITapGestureRecognizer(target: self, action: #selector(onTapGesture(touch:)))
            
            self.viewOverLay = UIView(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.view.bounds.width)!, height: (self.navigationController?.view.bounds.height)!))
            viewOverLay.backgroundColor = .black
            self.navigationController?.view.addSubview(viewOverLay)
            viewOverLay.frame.size.height = (self.navigationController?.view.bounds.height)!
            viewOverLay.alpha = 0.0
            
            
            self.viewOverLay.addGestureRecognizer(tapGesture!)
            
            
            let imageSize = CGSize(width: 100, height: 100)
            let centerScreen = self.view.center
            let imageFrame = CGRect(x: centerScreen.x - imageSize.width / 2, y: centerScreen.y - imageSize.height/2, width: imageSize.width, height: imageSize.height)
            swipeTutorialView = UIView(frame: imageFrame)
            swipeTutorialView.backgroundColor = .green
            swipeTutorialView.layer.cornerRadius = 25
            swipeTutorialView.layer.borderWidth = 2
            self.navigationController?.view.addSubview(swipeTutorialView)
            self.swipeTutorialView.addGestureRecognizer(tapGesture2!)
            
            UIView.animate(withDuration: 0.3) { self.viewOverLay.alpha = 0.50 }
            showSwipeTutorial = false
        }
    }
    // MARK: - Functions
    private func newVCFromStoryboard(storyboardID: String) -> TPPlanVC {
        return UIStoryboard(name: "Main", bundle: nil) .
            instantiateViewController(withIdentifier: storyboardID) as! TPPlanVC
    }
    
    // MARK: - Page Navigation Functions
    
    // SCROLLS TO NEXT VIEW CONTROLLER
    func scrollToNextViewController() {
        if let visibleViewController = viewControllers?.first,
            let nextViewController = pageViewController(self, viewControllerAfter : visibleViewController) {
            scrollToViewController(viewController: nextViewController)
        }
    }
    // SCROLL TO SPECIFIC VIEW CONTROLLER
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
    // NOTIFIES DELEGATE OF NEW PAGE INDEX
    private func notifyTutorialDelegateOfNewIndex() {
        if let firstViewController = viewControllers?.first as? TPPlanVC,
            let index = orderedViewControllers.firstIndex(of: firstViewController) {
            tpPageDelegate?.tpPageVC(tpPageVC: self,
                                             didUpdatePageIndex: index)
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == StoryBoardKeys.notepadSegue {
            let newNotepadVC = segue.destination as! TPNotepadVC
            newNotepadVC.dataSourceType = dataSourceType
            newNotepadVC.dataSourceIndex = self.currentVCIndex
            newNotepadVC.tpPageDelegate = self
            
            // directly injecting the model
            //newNotepadVC.dataSourceNotes = getModelData(type: dataSourceType).planArray[currentVCIndex].notes
        }
    }
}

// MARK: - Extensions, DataSource, and Delegates


// MARK: - UIPageViewControllerDataSource
extension TPPageVC: UIPageViewControllerDataSource {
    // FINDS THE NEXT VIEW CONTROLLER WHEN USER SWIPES
    // VIEW CONTROLLER BEFORE
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let newViewController = viewController as? TPPlanVC,
            let viewControllerIndex = orderedViewControllers.firstIndex(of: newViewController) else {
                return nil
        }

        let previousIndex = viewControllerIndex - 1
        
        // user is on the first view controller and swiped left
        guard previousIndex >= 0 else {
            //return orderedViewControllers.last
            return nil
        }
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
        return orderedViewControllers[previousIndex]
    }
    
    // VIEW CONTROLLER AFTER
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter
        viewController: UIViewController) -> UIViewController? {
        guard let newViewController = viewController as? TPPlanVC,
            let viewControllerIndex = orderedViewControllers.firstIndex(of: newViewController) else {
                return nil
        }
        
        let nextIndex = viewControllerIndex + 1
        let orderedViewControllersCount = orderedViewControllers.count
        
        // user is on the last view controller and swiped right
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

extension TPPageVC: UIPageViewControllerDelegate {
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        // PAGE CHANGED
        notifyTutorialDelegateOfNewIndex()
    
    }
    
}

// MARK: - TPPageVCDelegate
extension TPPageVC: TPPageVCDelegate {
   
    func tpPageVC(tpPageVC: TPPageVC, didUpdatePageCount count: Int) {
        // page count changed
    }
    
    func tpPageVC(tpPageVC: TPPageVC, didUpdatePageIndex index: Int) {
        // updates the currentVCIndex
        self.currentVCIndex = index
    }
    
}
// MARK: - TPPageVCNavItemDelegate
extension TPPageVC: TPPageVCNavItemDelegate {
    func toggleKeyboardIsDisplayed() {
        editingText.toggle()
    }
}


protocol dataUpdaterXDelegate: class {
    func someoneCallThisFunction(text: String)
}

extension TPPageVC: dataUpdaterXDelegate {
    // implement the function here
    // notes calls this function. 
    func someoneCallThisFunction(text: String){
        print("THIS FUNCTION WAS CALLED!!")
        print("Printing passed string variable...")
        print(text)
    }
}
