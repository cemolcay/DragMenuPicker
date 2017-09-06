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
    dragControl?.title = "hey hey hey"
    dragControl?.items = ["First", "Second", "Third"]
    dragControl?.direction = .vertical
  }
}

