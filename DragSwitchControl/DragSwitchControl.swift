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

extension UIView {
  func debugLayer(color: UIColor = .red) {
    layer.borderColor = color.cgColor
    layer.borderWidth = 1
  }
}

/// Action handler on drag menu item selection.
public typealias DragMenuSelectItemAction = (_ item: String, _ index: Int) -> Void

/// Applies view or layer style to menu and its every item in a block.
public typealias DragMenuApplyStyleAction = (_ menu: DragMenuView, _ item: DragMenuItemView) -> Void

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

@objc public protocol DragMenuViewDelegate {
  @objc optional func dragMenuViewWillDisplayMenu(_ dragMenuView: DragMenuView)
  @objc optional func dragMenuViewDidDisplayMenu(_ dragMenuView: DragMenuView)
  @objc optional func dragMenuViewWillDismissMenu(_ dragMenuView: DragMenuView)
  @objc optional func dragMenuViewDidDismissMenu(_ dragMenuView: DragMenuView)
}

/// Drag menu view with items and display options.
public class DragMenuView: UIView {
  /// Selection items in drag menu.
  public var items = [DragMenuItemView]()
  /// Triggers the menu scroll with a distance to edges. Defaults 40.
  public var scrollingThreshold = CGFloat(40)
  /// Maximum speed of scrolling. If scroll speed is not increased than it's always scrolls on that speed. Defaults 10.
  public var maximumScrollingSpeed = CGFloat(10)
  /// An option for controlling scroll speed over time. Scroll speed increases to `maximumScrollingSpeed` in two seconds.
  public var isScrollSpeedIncreases = true
  /// A reference the direction of drag menu.
  private var direction: DragMenuDirection
  /// Returns true if menu is scrolling any direction.
  public private(set) var isScrolling = false { didSet { print("Scrolling \(isScrolling)") } }
  /// A timer object to update scrolling animation of menu.
  private var scrollTimer: Timer?
  /// Actual menu view, masked into parent to create scrolling effect.
  public private(set) var menuView = UIView()
  /// Delegate that informs display status.
  public weak var delegate: DragMenuViewDelegate?

  /// Helper enum to scroll menu in a direction.
  private enum ScrollDirection {
    case left, right, up, down
  }

  /// Initilizes the drag menu with items, direction and item options.
  ///
  /// - Parameters:
  ///   - items: Selection items of drag menu.
  ///   - initalSelection: Initially selected item index.
  ///   - estimatedItemSize: Estimated item width if menu is horizontal, estimated item height if menu is vertical.
  ///   - controlBounds: Reference `DragSwitchControl`'s bounds relative to window to fit menu properly in screen real estate.
  ///   - direction: Direction of menu. Either horizontal or vertical.
  ///   - margins: Margins from screen edges. Left and right if menu is horizontal, top and bottom if menu is vertical.
  ///   - backgroundColor: Backgronud color of drag menu.
  ///   - highlightedColor: Highlighted item background color in drag menu.
  ///   - textColor: Text color of selection items in drag menu.
  ///   - highlightedTextColor: Hihglighted text color of selected item in drag menu.
  ///   - font: Font of selection items in drag menu.
  ///   - applyStyle: Style drag menu and its every item with this optional function.
  public init(items: [String], initalSelection: Int, estimatedItemSize: CGFloat, controlBounds: CGRect, direction: DragMenuDirection, margins: CGFloat, backgroundColor: UIColor, highlightedColor: UIColor, textColor: UIColor, highlightedTextColor: UIColor, font: UIFont, applyStyle: DragMenuApplyStyleAction? = nil) {
    self.direction = direction
    super.init(frame: CGRect(
      x: direction == .horizontal ? -controlBounds.minX + margins : 0,
      y: direction == .horizontal ? 0 : -controlBounds.minY + margins,
      width: direction == .horizontal ? UIScreen.main.bounds.width - (margins * 2) : controlBounds.width,
      height: direction == .horizontal ? controlBounds.height : UIScreen.main.bounds.height - (margins * 2)))

    clipsToBounds = true
    addSubview(menuView)

    debugLayer()
    menuView.debugLayer(color: .blue)

    addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil)) // add dummy gesture recognizer
    menuView.backgroundColor = backgroundColor
    menuView.frame = CGRect(
      x: direction == .horizontal ? -(CGFloat(initalSelection) * estimatedItemSize) + controlBounds.minX : 0,
      y: direction == .horizontal ? 0 : -(CGFloat(initalSelection) * estimatedItemSize) + controlBounds.minY - (controlBounds.size.height / 2),
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

      applyStyle?(self, itemView)
    }
  }

  public func didPan(gesture: UIPanGestureRecognizer) {
    return
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
    // Check if menu is scrollable
    if menuView.frame.width > frame.width || menuView.frame.height > frame.height {
      // Update menu position
      switch direction {
      case .horizontal:
        if position.x > bounds.minX && position.x < bounds.minX + scrollingThreshold { // Scroll left
          scroll(to: .left)
        } else if position.x < bounds.maxX && position.x > bounds.maxX - scrollingThreshold { // Scroll right
          scroll(to: .right)
        } else {
          stopScrolling()
        }
      case .vertical:
        if position.y > bounds.minY && position.y < bounds.minY + scrollingThreshold { // Scroll up
          scroll(to: .up)
        } else if position.y < bounds.maxY && position.y > bounds.maxY - scrollingThreshold { // Scroll down
          scroll(to: .down)
        } else {
          stopScrolling()
        }
      }
    }

    // Update highlighted item
    items.forEach({ $0.isHighlighted = $0.frame.contains(convert(position, to: menuView)) })
  }

  private func scroll(to: ScrollDirection) {
    if isScrolling {
      return
    }

    isScrolling = true
    scrollTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true, block: { [weak self] _ in
      guard let this = self else { return }
      switch to {
      case .left:
        var newPosition = this.menuView.frame.origin.x + this.maximumScrollingSpeed
        if newPosition > 0 {
          newPosition = 0
        }
        this.menuView.layer.frame.origin.x = newPosition
      case .right:
        var newPosition = this.menuView.frame.origin.x - this.maximumScrollingSpeed
        if newPosition <= this.frame.size.width - this.menuView.frame.size.width {
          newPosition = this.frame.size.width - this.menuView.frame.size.width
        }
        this.menuView.layer.frame.origin.x = newPosition
      case .up:
        var newPosition = this.menuView.frame.origin.y + this.maximumScrollingSpeed
        if newPosition > 0 {
          newPosition = 0
        }
        this.menuView.frame.origin.y = newPosition
      case .down:
        var newPosition = this.menuView.frame.origin.y - this.maximumScrollingSpeed
        if newPosition <= this.frame.size.height - this.menuView.frame.size.height {
          newPosition = this.frame.size.height - this.menuView.frame.size.height
        }
        this.menuView.frame.origin.y = newPosition
      }
    })
  }

  private func stopScrolling() {
    scrollTimer?.invalidate()
    scrollTimer = nil
    isScrolling = false
  }
}

/// A custom button with ability to select an option from its items menu with drag gesture.
@IBDesignable public class DragSwitchControl: UIView, DragMenuViewDelegate {
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
  /// Apply custom view or layer styles for `DragMenuView` and its every `DragMenuItemView` with this function.
  public var applyMenuStyle: DragMenuApplyStyleAction?
  /// Informs about drag menu status via `DragMenuViewDelegate`.
  public weak var menuDelegate: DragMenuViewDelegate?

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
  ///   - applyMenuStyle: Apply custom style to `DragMenuView` and its every `DragMenuItemView` with this optional function.
  public init(frame: CGRect, title: String, items: [String], initialSelectionIndex: Int = 0, didSelectItem: @escaping DragMenuSelectItemAction, applyMenuStyle: DragMenuApplyStyleAction? = nil) {
    super.init(frame: frame)
    self.title = title
    self.items = items
    self.selectedItemIndex = initialSelectionIndex
    self.didSelectItem = didSelectItem
    self.applyMenuStyle = applyMenuStyle
    addGestureRecognizer(UITapGestureRecognizer(target: nil, action: nil))
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
      controlBounds: convert(bounds, to: nil),
      direction: direction,
      margins: margins,
      backgroundColor: dragMenuBackgroundColor,
      highlightedColor: dragMenuHightlightedItemColor,
      textColor: itemTextColor,
      highlightedTextColor: highlightedTextColor,
      font: itemFont,
      applyStyle: applyMenuStyle)
  }

  // MARK: Handle touches

  public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard dragMenu == nil else { return }
    dragMenu = createDragMenu()
    guard let dragMenu = self.dragMenu else { return }
    menuDelegate?.dragMenuViewWillDisplayMenu?(dragMenu)
    addSubview(dragMenu)
    menuDelegate?.dragMenuViewDidDisplayMenu?(dragMenu)
  }

  public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard isOpen,
      let dragMenu = dragMenu,
      let touchLocation = touches.first?.location(in: dragMenu) else { return }
    dragMenu.updateMenu(for: touchLocation)
  }

  public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
    guard let dragMenu = self.dragMenu else { return }
    menuDelegate?.dragMenuViewWillDismissMenu?(dragMenu)

    if let selectedItem = dragMenu.items.filter({ $0.isHighlighted }).first {
      self.selectedItemIndex = selectedItem.tag
      self.didSelectItem(items[selectedItemIndex], selectedItemIndex)
    }

    dragMenu.removeFromSuperview()
    menuDelegate?.dragMenuViewDidDismissMenu?(dragMenu)
    self.dragMenu = nil
  }

  // MARK: DragMenuViewDelegate

  public func dragMenuViewWillDisplayMenu(_ dragMenuView: DragMenuView) {
    guard let dragMenu = self.dragMenu else { return }
    menuDelegate?.dragMenuViewWillDisplayMenu?(dragMenu)
  }

  public func dragMenuViewDidDisplayMenu(_ dragMenuView: DragMenuView) {
    guard let dragMenu = self.dragMenu else { return }
    menuDelegate?.dragMenuViewDidDisplayMenu?(dragMenu)
  }

  public func dragMenuViewWillDismissMenu(_ dragMenuView: DragMenuView) {
    guard let dragMenu = self.dragMenu else { return }
    menuDelegate?.dragMenuViewWillDismissMenu?(dragMenu)
  }

  public func dragMenuViewDidDismissMenu(_ dragMenuView: DragMenuView) {
    guard let dragMenu = self.dragMenu else { return }
    menuDelegate?.dragMenuViewDidDismissMenu?(dragMenu)
  }
}
