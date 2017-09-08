//
//  ViewController.swift
//  DragSwitchControl
//
//  Created by Cem Olcay on 06/09/2017.
//  Copyright © 2017 cemolcay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var scrollView: UIScrollView?
  @IBOutlet weak var dragControl: DragSwitchControl?

  override func viewDidLoad() {
    super.viewDidLoad()
    scrollView?.contentSize.height = 2000
    dragControl?.title = "Select an option"
    dragControl?.direction = .vertical
    dragControl?.items = ["First", "Second", "Third", "Fourth", "Other", "Another", "Item 2", "Item 3"]
    dragControl?.didSelectItem = { item, index in
      print("\(item) selected at index \(index)")
    }
  }
}
