//
//  ViewController.swift
//  DragSwitchControl
//
//  Created by Cem Olcay on 06/09/2017.
//  Copyright © 2017 cemolcay. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DragMenuViewDelegate {
  @IBOutlet weak var scrollView: UIScrollView?
  @IBOutlet weak var dragControl: DragSwitchControl?

  override func viewDidLoad() {
    super.viewDidLoad()
    scrollView?.contentSize.height = 2000
    dragControl?.title = "Select an option"
    dragControl?.items = ["First", "Second", "Third", "Fourth", "Other", "Another", "Item 2", "Item 3"]
    dragControl?.direction = .horizontal
    dragControl?.margins = 20
    dragControl?.menuDelegate = self
    dragControl?.didSelectItem = { item, index in
      print("\(item) selected at index \(index)")
    }
  }

  // MARK: DragMenuViewDelegate

  func dragMenuViewWillDisplayMenu(_ dragMenuView: DragMenuView) {
    scrollView?.panGestureRecognizer.isEnabled = false
  }

  func dragMenuViewDidDisplayMenu(_ dragMenuView: DragMenuView) {
    scrollView?.panGestureRecognizer.isEnabled = true
  }
}
