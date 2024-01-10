import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meals/provider/meals_provider.dart';

enum Filter { gluten, lactose, vagetarian, vegan }

class FilterNotifier extends StateNotifier<Map<Filter, bool>> {
  FilterNotifier()
      : super({
          Filter.gluten: false,
          Filter.lactose: false,
          Filter.vagetarian: false,
          Filter.vegan: false
        });

  void setFilters(Map<Filter, bool> chooseFilters) {
    state = chooseFilters;
  }

  void setFilter(Filter filter, bool status) {
    state = {...state, filter: status};
  }
}

final filterProvider = StateNotifierProvider<FilterNotifier, Map<Filter, bool>>(
    (ref) => FilterNotifier());

final filteredMealsProvider = Provider((ref) {
  final meals = ref.watch(mealsProvider);
  final activeFilters = ref.watch(filterProvider);

  return meals.where((meal) {
    if (activeFilters[Filter.gluten]! && !meal.isGlutenFree) {
      return false;
    }

    if (activeFilters[Filter.lactose]! && !meal.isLactoseFree) {
      return false;
    }

    if (activeFilters[Filter.vagetarian]! && !meal.isVegetarian) {
      return false;
    }

    if (activeFilters[Filter.vegan]! && !meal.isVegan) {
      return false;
    }

    return true;
  }).toList();
});
