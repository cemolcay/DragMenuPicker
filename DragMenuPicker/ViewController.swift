//
//  ViewController.swift
//  DragMenuPicker
//
//  Created by Cem Olcay on 06/09/2017.
//  Copyright © 2017 cemolcay. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DragMenuViewDelegate {
  @IBOutlet weak var scrollView: UIScrollView?
  @IBOutlet weak var horizontalDragPicker: DragMenuPicker?
  @IBOutlet weak var verticalDragPicker: DragMenuPicker?

  override func viewDidLoad() {
    super.viewDidLoad()

    scrollView?.contentSize.height = 2000
    let items = ["First", "Second", "Third", "Fourth", "Other", "Another", "Item 2", "Item 3"]

    // Horizontal DragSwitchPicker
    horizontalDragPicker?.title = "Horizontal Picker"
    horizontalDragPicker?.items = items
    horizontalDragPicker?.direction = .horizontal
    horizontalDragPicker?.margins = 20
    horizontalDragPicker?.menuDelegate = self
    horizontalDragPicker?.didSelectItem = { item, index in
      print("\(item) selected at index \(index)")
    }

    // VerticalDragPicker
    verticalDragPicker?.title = "Vertical Picker"
    verticalDragPicker?.items = items
    verticalDragPicker?.direction = .vertical
    verticalDragPicker?.margins = 40
    verticalDragPicker?.menuDelegate = self
    verticalDragPicker?.didSelectItem = { item, index in
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
