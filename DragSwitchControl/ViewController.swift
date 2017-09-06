//
//  ViewController.swift
//  DragSwitchControl
//
//  Created by Cem Olcay on 06/09/2017.
//  Copyright © 2017 cemolcay. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var dragControl: DragSwitchControl?

  override func viewDidLoad() {
    super.viewDidLoad()
    dragControl?.title = "Select an option"
    dragControl?.items = ["First", "Second", "Third", "Fourth", "Some", "Other", "Long", "List", "Item", "Long List Item Hey", "Other Item", "Another Item"]
    dragControl?.direction = .horizontal
//    dragControl?.margins = 80
    dragControl?.didSelectItem = { item, index in
      print("\(item) selected at index \(index)")
    }
  }
}

