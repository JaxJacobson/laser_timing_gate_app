// sortlist.dart
// Mayson Ostermeyer 04/14/2026
//
// This file defines the SortList class and SortOption enum used for sorting .txt files
// The items can be sorted by date (newest to oldest or oldest to newest) or alphabetically (A-Z or Z-A)

// IMPORTS
import 'dart:io';


// Enum for sorting options
// Enum means a type that can have a fixed set of constant values. In this case, SortOption defines the different ways we can sort our list of files.
enum SortOption {
  newestToOldest,
  oldestToNewest,
  aToZ,
  zToA,
}

class SortFiles {
  // Static method to sort a list of files based on the selected sorting option
  static List<File> sortFiles(List<File> files, SortOption sortOption) {

    // Create a copy of the original list to avoid modifying it directly
    final sortedFiles = List<File>.from(files);

    // Sort the files based on the selected sorting option using a switch statement
    switch (sortOption) {
      // sortedFiles.sort() is a method that sorts the list in place. The comparison function provided to sort() determines the order of the elements.
      // It compares two files (a and b) by the logic defined in the function. The function should return a negative number if a should come before b,
      // a positive number if a should come after b, or zero if they are equal in terms of sorting order. It will contiue to loop through the list and
      // compare each pair of files until the entire list is sorted according to the specified criteria.

      // Example: A to Z
      // Files: Mayson.txt, Alice.txt, Zach.txt, Bob.txt

      // Iteration 1
      // Comparison: Alice.txt vs Mayson.txt -> returns a negative number (Alice comes before Mayson)
      // Files: Alice.txt, Mayson.txt, Zach.txt, Bob.txt
      // Comparison: Zach.txt vs Mayson.txt -> returns a positive number (Zach comes after Mayson)
      // Files: Alice.txt, Mayson.txt, Zach.txt, Bob.txt
      // Comparison: Bob.txt vs Zach.txt -> returns a negative number (Bob comes before Zach)
      // Files: Alice.txt, Mayson.txt, Bob.txt, Zach.txt

      // Iteration 2
      // Comparison: Mayson.txt vs Alice.txt -> returns a positive number (Mayson comes after Alice)
      // Files: Alice.txt, Mayson.txt, Bob.txt, Zach.txt
      // Comparison: Bob.txt vs Mayson.txt -> returns a negative number (Bob comes before Mayson)
      // Files: Alice.txt, Bob.txt, Mayson.txt, Zach.txt
      // Comparison: Zach.txt vs Mayson.txt -> returns a positive number (Zach comes after Mayson)
      // Files: Alice.txt, Bob.txt, Mayson.txt, Zach.txt

      // Iteration 3
      // Comparison: Bob.txt vs Alice.txt -> returns a positive number (Bob comes after Alice)
      // Files: Alice.txt, Bob.txt, Mayson.txt, Zach.txt
      // Comparison: Mayson.txt vs Bob.txt -> returns a positive number (Mayson comes after Bob)
      // Files: Alice.txt, Bob.txt, Mayson.txt, Zach.txt
      // Comparison: Zach.txt vs Mayson.txt -> returns a positive number (Zach comes after Mayson)
      // Files: Alice.txt, Bob.txt, Mayson.txt, Zach.txt
      // Final sorted list: Alice.txt, Bob.txt, Mayson.txt, Zach.txt

      case SortOption.newestToOldest:
      // Sort files by date, with the newest files first
        sortedFiles.sort((a, b) {
          final aDate = a.statSync().changed;
          final bDate = b.statSync().changed;
          return bDate.compareTo(aDate);
        });
        // Stops the files from being sorted by the next case statement. 
        break;

      case SortOption.oldestToNewest:
      // Sort files by date, with the oldest files first
        sortedFiles.sort((a, b) {
          final aDate = a.statSync().changed;
          final bDate = b.statSync().changed;
          return aDate.compareTo(bDate);
        });
        break;

      case SortOption.aToZ:
      // Sort files alphabetically from A to Z
        sortedFiles.sort((a, b) {
          final aName = a.path.split('\\').last.toLowerCase();
          final bName = b.path.split('\\').last.toLowerCase();
          return aName.compareTo(bName);
        });
        break;

      case SortOption.zToA:
      // Sort files alphabetically from Z to A
        sortedFiles.sort((a, b) {
          final aName = a.path.split('\\').last.toLowerCase();
          final bName = b.path.split('\\').last.toLowerCase();
          return bName.compareTo(aName);
        });
        break;
    }

    return sortedFiles;
  }
}