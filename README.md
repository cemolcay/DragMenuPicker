DragMenuPicker
===

A custom picker lets you pick an option from its auto scrolling menu without lifting your finger up.

You can either use the `@IBDesignable` picker button `DragMenuPicker` or create your own with `DragMenuView` which implements all picker logic.

Demo
----
![alt tag](https://github.com/cemolcay/DragMenuPicker/raw/master/Demo.gif)

Requirements
----

- iOS 9.0+
- Swift 3.0+

Install
----

```
pod 'DragMenuPicker'
```

Usage
----

Create a `DragMenuPicker` from either storyboard or programmatically.  
Set its `title` and `items` property to shown in menu.  
Set its `didSelectItem` property or implement `dragMenuView(_ dragMenuView: DragMenuView, didSelect item: String, at index: Int)` delegate method to set your action after picking.  
You can also set its `direction`, either horizontal or vertical with `margins` to screen edges.  


``` swift
horizontalDragPicker?.title = "Horizontal Picker"
horizontalDragPicker?.items = ["First", "Second", "Third", "Fourth", "Other", "Another", "Item 2", "Item 3"]
horizontalDragPicker?.direction = .horizontal
horizontalDragPicker?.margins = 20
horizontalDragPicker?.menuDelegate = self
horizontalDragPicker?.didSelectItem = { item, index in
  print("\(item) selected at index \(index)")
}
```
  
  
`DragMenuPicker` shows `DragMenuView` with `DragMenuItemView`s inside when you touch down the picker. It disappears after you pick something from menu or cancel picking by lifting your finger up outside of the menu.

They are heavily customisable. You can set `applyStyle` property which callbacks you prototype menu and item that you can style and it applies it to menu.

Also there are `@IBInspectable` properties on `DragMenuPicker` that you can style basic properties inside storyboard.