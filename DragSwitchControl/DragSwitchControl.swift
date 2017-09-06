//
//  DragSwitchControl.swift
//  DragSwitchControl
//
//  Created by Cem Olcay on 06/09/2017.
//  Copyright © 2017 cemolcay. All rights reserved.
//
//  https://github.com/cemolcay/DragSwitchControl
//

import UIKit

/// Action handler on drag menu item selection.
public typealias DragMenuSelectItemAction = (_ item: String, _ index: Int) -> Void

/// Direction of drag menu.
public enum DragMenuDirection {
  /// Left to right, horizontal direction.
  case horizontal
  /// Top to bottom, vertical direction.
  case vertical
}

/// An item view in drag menu.
public class DragMenuItemView: UILabel {
  public var highlightedBackgroundColor: UIColor = .clear
  public var defaultTextColor: UIColor = .black

  public override var isHighlighted: Bool {
    didSet {
      backgroundColor = isHighlighted ? highlightedBackgroundColor : .clear
      textColor = isHighlighted ? highlightedTextColor : defaultTextColor
    }
  }
}

/// Drag menu view with items and display options.
public class DragMenuView: UIView {
  /// Selection items in drag menu.
  public var items = [DragMenuItemView]()
  /// Triggers the menu scroll with a distance to edges. Defaults 20.
  public var scrollingThreshold = CGFloat(20)
  /// Maximum speed of scrolling. If scroll speed is not increased than it's always scrolls on that speed. Defaults 10.
  public var maximumScrollingSpeed = CGFloat(10)
  /// An option for controlling scroll speed over time. Scroll speed increases to `maximumScrollingSpeed` in two seconds.
  public var isScrollSpeedIncreases = true
  /// A reference the direction of drag menu.
  private var direction: DragMenuDirection

  /// Actual menu view, masked into parent to create scrolling effect.
  public private(set) var menuView = UIView()

  /// Initilizes the drag menu with items, direction and item options.
  ///
  /// - Parameters:
  ///   - items: Selection items of drag menu.
  ///   - initalSelection: Initially selected item index.
  ///   - estimatedItemSize: Estimated item width if menu is horizontal, estimated item height if menu is vertical.
  ///   - controlBounds: Reference `DragSwitchControl`'s bounds to fit menu properly.
  ///   - direction: Direction of menu. Either horizontal or vertical.
  ///   - margins: Margins from screen edges. Left and right if menu is horizontal, top and bottom if menu is vertical.
  ///   - backgroundColor: Backgronud color of drag menu.
  ///   - highlightedColor: Highlighted item background color in drag menu.
  ///   - textColor: Text color of selection items in drag menu.
  ///   - highlightedTextColor: Hihglighted text color of selected item in drag menu.
  ///   - font: Font of selection items in drag menu.
  public init(items: [String], initalSelection: Int, estimatedItemSize: CGFloat, controlBounds: CGRect, direction: DragMenuDirection, margins: CGFloat, backgroundColor: UIColor, highlightedColor: UIColor, textColor: UIColor, highlightedTextColor: UIColor, font: UIFont) {
    self.direction = direction
    super.init(frame: CGRect(
      x: direction == .horizontal ? margins : 0,
      y: direction == .horizontal ? 0 : margins,
      width: direction == .horizontal ? min(CGFloat(items.count) * estimatedItemSize, UIScreen.main.bounds.width - (margins * 2)) : controlBounds.width,
      height: direction == .horizontal ? controlBounds.height : min(CGFloat(items.count) * estimatedItemSize, UIScreen.main.bounds.height - (margins * 2))))

    clipsToBounds = true
    addSubview(menuView)
    
    menuView.backgroundColor = backgroundColor
    menuView.frame = CGRect(
      x: 0,
      y: 0,
      width: direction == .horizontal ? CGFloat(items.count) * estimatedItemSize : controlBounds.width,
      height: direction == .horizontal ? controlBounds.height : CGFloat(items.count) * estimatedItemSize)

    for (index, item) in items.enumerated() {
      let itemView = DragMenuItemView(frame: CGRect(
        x: direction == .horizontal ? CGFloat(index) * estimatedItemSize : 0,
        y: direction == .horizontal ? 0 : CGFloat(index) * estimatedItemSize,
        width: direction == .horizontal ? estimatedItemSize : controlBounds.width,
        height: direction == .horizontal ? controlBounds.height : estimatedItemSize))
      itemView.highlightedBackgroundColor = highlightedColor
      itemView.tag = index
      itemView.text = item
      itemView.textAlignment = .center
      itemView.textColor = textColor
      itemView.highlightedTextColor = highlightedTextColor
      itemView.font = font
      self.items.append(itemView)
      menuView.addSubview(itemView)
    }
  }
  
  public required init?(coder aDecoder: NSCoder) {
    direction = .horizontal
    super.init(coder: aDecoder)
  }

  // MARK: Update Menu

  /// Updates the selected item and menu scroll for given touch position.
  ///
  /// - Parameter location: Current position of touch on drag menu.
  public func updateMenu(for position: CGPoint) {
    items.forEach({ $0.isHighlighted = $0.frame.contains(position) })
  }
}

/// A custom button with ability to select an option from its items menu with drag gesture.
@IBDesignable public class DragSwitchControl: UIView {
  /// The title of the button.
  @IBInspectable public var title = "" { didSet { setNeedsLayout() }}
  /// Items of drag menu.
  public var items = [String]()
  /// Index of currently selected item in drag menu. Defaults 0.
  @IBInspectable public var selectedItemIndex = 0 { didSet { setNeedsLayout() }}
  /// Action on item selection from draw menu.
  public var didSelectItem: DragMenuSelectItemAction = { _, _ in return }
  /// Estimated minimum size for each item. Width size for horizontal, height size for vertical drag memu. Defaults 60.
  @IBInspectable public var estimatedItemSize = CGFloat(60)
  /// Direction of drag menu. Either horizontal or vertical.
  public var direction = DragMenuDirection.horizontal
  /// Margins from edges of screen. Left and right margins for horizontal, top and bottom margins for vertical drag menu. Defaults 0
  @IBInspectable public var margins = CGFloat(0)

  /// Read-only property to get info about drag menu is shown or not.
  public dynamic var isOpen: Bool { return dragMenu != nil }
  /// Title label of button.
  public private(set) var titleLabel = UILabel()
  /// Selected item label of button.
  public private(set) var itemLabel = UILabel()
  /// Stack view of button with stack of labels.
  public private(set) var buttonStack = UIStackView()
  /// Drag menu with selection of items. Nil if not shown.
  public private(set) var dragMenu: DragMenuView?

  /// Text color of title label. Defaults black.
  @IBInspectable public var titleTextColor = UIColor.black { didSet { setNeedsLayout() }}
  /// Text color of selected item label. Defaults black.
  @IBInspectable public var itemTextColor = UIColor.black { didSet { setNeedsLayout() }}
  /// Highlighted text color of selected item label. Defaults black.
  @IBInspectable public var highlightedTextColor = UIColor.black { didSet { setNeedsLayout() }}
  /// Font of title label. Defaults 13.
  @IBInspectable public var titleFont = UIFont.systemFont(ofSize: 13) { didSet { setNeedsLayout() }}
  /// Font of selected item label. Defaults 15.
  @IBInspectable public var itemFont = UIFont.systemFont(ofSize: 15) { didSet { setNeedsLayout() }}
  /// Background color of drag menu. Defaults gray.
  @IBInspectable public var dragMenuBackgroundColor = UIColor.gray
  /// Highlighted item background color in drag menu. Defaults yellow.
  @IBInspectable public var dragMenuHightlightedItemColor = UIColor.yellow

  // MARK: Init

  /// Init the control with title, items and action.
  ///
  /// - Parameters:
  ///   - frame: Frame of control.
  ///   - title: Title label text.
  ///   - items: Items of selection in drag menu.
  ///   - initialSelectionIndex: Initially selected item index.
  ///   - didSelectItem: Action on item selection.
  public init(frame: CGRect, title: String, items: [String], initialSelectionIndex: Int = 0, didSelectItem: @escaping DragMenuSelectItemAction) {
    super.init(frame: frame)
    self.title = title
    self.items = items
    self.selectedItemIndex = initialSelectionIndex
    self.didSelectItem = didSelectItem
    commonInit()
  }

  public override init(frame: CGRect) {
    super.init(frame: frame)
    commonInit()
  }
  
  public required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    commonInit()
  }

  private func commonInit() {
    buttonStack.axis = .vertical
    buttonStack.addArrangedSubview(titleLabel)
    buttonStack.addArrangedSubview(itemLabel)

    itemLabel.setContentHuggingPriority(UILayoutPriorityDefaultLow, for: .vertical)
    titleLabel.setContentHuggingPriority(UILayoutPriorityDefaultHigh, for: .vertical)

    addSubview(buttonStack)
  }

  // MARK: Lifecycle

  public override func layoutSubviews() {
    super.layoutSubviews()

    buttonStack.frame = bounds
    titleLabel.font = titleFont
    itemLabel.font = itemFont
    titleLabel.textColor = titleTextColor
    itemLabel.textColor = itemTextColor
    titleLabel.text = title
    itemLabel.text = items[selectedItemIndex]
  }

  // MARK: Drag menu

  private func createDragMenu() -> DragMenuView {
    return DragMenuView(
      items: items,
      initalSelection: selectedItemIndex,
      estimatedItemSize: estimatedItemSize,
      controlBounds: bounds,
      direction: direction,
      margins: margins,
      backgroundColor: dragMenuBackgroundColor,
      highlightedColor: dragMenuHightlightedItemColor,
      textColor: itemTextColor,
      highlightedTextColor: highlightedTextColor,
      font: itemFont)
  }

  // MARK: Handle touches

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard dragMenu == nil else { return }
    dragMenu = createDragMenu()
    guard let dragMenu = self.dragMenu else { return }
    addSubview(dragMenu)
  }

  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isOpen,
      let dragMenu = dragMenu,
      let touchLocation = touches.first?.location(in: dragMenu.menuView) else { return }
    dragMenu.updateMenu(for: touchLocation)
  }

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    if let selectedItem = dragMenu?.items.filter({ $0.isHighlighted }).first {
      self.selectedItemIndex = selectedItem.tag
      self.didSelectItem(items[selectedItemIndex], selectedItemIndex)
    }

    dragMenu?.removeFromSuperview()
    dragMenu = nil
  }
}
