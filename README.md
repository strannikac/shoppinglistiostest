# Shopping Lists

Get all shopping lists from API. \
Show shopping lists, show items in each shopping list. \
Add, edit, delete shopping lists and items in lists. \
Check / uncheck items in shopping list.

## Implementation

### Main controllers

ShoppingListTableViewController shows all lists. Also can add, edit, remove list.\
ShoppingListItemTableViewController shows items in list. Also can add, edit, remove item.

## Requirements

 - Xcode 12
 - Swift 5
 - Core Data
 - iOS 13.4+

## Solution

When application loaded, data is trying to update. Also customer can update data from all lists screen, but data will be updated one time per 30 minutes. 
