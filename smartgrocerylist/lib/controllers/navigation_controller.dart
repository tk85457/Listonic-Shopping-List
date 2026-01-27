import 'package:get/get.dart';
import 'package:smartgrocerylist/data/models/models.dart';

class NavigationController extends GetxController {
  // Current selected tab index
  final RxInt selectedTabIndex = 0.obs;

  // Current list being viewed (null when on lists screen)
  final Rx<ShoppingList?> currentList = Rx<ShoppingList?>(null);

  // Current screen title
  final RxString currentTitle = 'Lists'.obs;

  // Refresh triggers for screens
  final RxBool refreshTrash = false.obs;
  final RxBool refreshData = false.obs;

  // Update selected tab
  void setSelectedTab(int index) {
    selectedTabIndex.value = index;
    _updateTitle();
  }

  // Set current list and update title
  void setCurrentList(ShoppingList? list) {
    currentList.value = list;
    _updateTitle();
  }

  // Clear current list (when going back to lists screen)
  void clearCurrentList() {
    currentList.value = null;
    _updateTitle();
  }

  // Update title based on current state
  void _updateTitle() {
    if (currentList.value != null) {
      currentTitle.value = currentList.value!.name;
    } else {
      switch (selectedTabIndex.value) {
        case 0:
          currentTitle.value = 'Lists';
          break;
        case 1:
          currentTitle.value = 'Settings';
          break;
        case 2:
          currentTitle.value = 'Profile';
          break;
        default:
          currentTitle.value = 'Lists';
      }
    }
  }

  // Get current title
  String getTitle() {
    return currentTitle.value;
  }

  // Trigger trash refresh
  void triggerTrashRefresh() {
    refreshTrash.value = !refreshTrash.value;
    refreshData.value = !refreshData.value;
  }

  // Trigger global data refresh
  void triggerDataRefresh() {
    refreshData.value = !refreshData.value;
  }
}
