import 'package:flutter/material.dart';
import 'package:meals/data/dummy_data.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/screen/categories.dart';
import 'package:meals/screen/filters.dart';
import 'package:meals/screen/meals.dart';
import 'package:meals/widgets/main_drawer.dart';

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() => _TabsScreenState();
}

const kInitialFilters = {
  Filter.gluten: false,
  Filter.lactose: false,
  Filter.vagetarian: false,
  Filter.vegan: false,
};

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  final List<Meal> favoritesList = [];
  Map<Filter, bool> _selelctedFilters = kInitialFilters;

  void _showInfoMessage(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg)),
    );
  }

  void _onDrawerItemClicked(String route) async {
    Navigator.of(context).pop();
    if (route == 'filters') {
      final result = await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
          builder: (ctx) =>  FiltersScreen(
            currentFilters: _selelctedFilters,
          ),
        ),
      );
      setState(() {
        _selelctedFilters = result ?? kInitialFilters;
      });
    }
  }

  void _manageFavoriteState(Meal meal) {
    final isExsists = favoritesList.contains(meal);

    if (isExsists) {
      setState(() {
        favoritesList.remove(meal);
      });
      _showInfoMessage("Meal is no longer a favorite.");
    } else {
      setState(() {
        favoritesList.add(meal);
      });
      _showInfoMessage("Meal add to favorite.");
    }
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableMeals = dummyMeals.where((meal) {
      if (_selelctedFilters[Filter.gluten]! && !meal.isGlutenFree) {
        return false;
      }

      if (_selelctedFilters[Filter.lactose]! && !meal.isLactoseFree) {
        return false;
      }

      if (_selelctedFilters[Filter.vagetarian]! && !meal.isVegetarian) {
        return false;
      }

      if (_selelctedFilters[Filter.vegan]! && !meal.isVegan) {
        return false;
      }

      return true;
    }).toList();

    Widget activePage = CategoriesScreen(
      onToggleFavorite: _manageFavoriteState,
      availableMeals: availableMeals,
    );
    var activePgaeTitle = "Categories";

    if (_selectedPageIndex == 1) {
      activePage = MealsScreen(
        meals: favoritesList,
        onToggleFavorite: (meal) {
          _manageFavoriteState(meal);
        },
      );
      activePgaeTitle = "Your Favorites";
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activePgaeTitle),
      ),
      body: activePage,
      drawer: MainDrawer(
        onDrawerItemClicked: _onDrawerItemClicked,
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.set_meal), label: "Categrios"),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: "Favorites"),
        ],
      ),
    );
  }
}
