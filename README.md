# laser_timing_gate_app

By Jax Jacobson and Mayson Ostermeyer

## Why This Project Exists


This whole project started because our track program has a freelap timing gate system that we dislike. This system uses a magnetic field and a chip sensor worn by the runner to measure the time it takes between hitting the first field and the second field. This was innacurate, frustrating, and we knew that we could make a better version. Completely from the ground up, Mayson built a laser timing gate that was more precise and reliable than the freelap system. We just needed a user friendly app to go with it. Jax and Mayson's software engineering class was also asking for a semester project. This was a perfect excuse to finish the laser timing gate and use it as a project in our class.


## How To Run Our App

This app was built specifically for Mayson's custom built laser timing gate system. That being said, we used an HC-05 bluetooth (around $10) module connecting the two through an arduino. This was extremely finicky and not easy. When trying to connect your bluetooth module, make sure to verify which COM ports are available on your computer. Some may work, some may not, but the BT_HC05.dart file will require you to edit the portName variable in order to start a session. 
I will describe how to start the application through VSCode

### Step 1- Installing Flutter and Dart
 Add the flutter extension to VSCode (https://marketplace.visualstudio.com/items?itemName=Dart-Code.flutter)
 If you get a popup about a missing flutter SDK, you can click on the "Download SDK" button. If this popup didn't happen, open the command palette with control+shift+p. In the command pallete you will type flutter and select Flutter:New Project. This will ask to locate the Flutter SDK, in which you will select "Download SDK." Now you can choose where you want flutter to install and click "Clone FLutter." A popup will ask to add SDK to path. Click "Add SDK to Path." If you missed this popup, you can click the notification icon on the bottom right to see it. If it is still not there, you may need to delete flutter and reinstall because this is essential. Another popup will signify that dart is missing packages and needs to run "pub get." Do this and the application should be ready to start.

 ### Step 2- Installing Missing Dependencies
 Type "flutter doctor" into terminal to see what needs to be downloaded in order to run. The Android toolchain does NOT need to be installed unless you plan to implement this onto a phone. Visual Studio Build Tools (latest version) is required, but Visual Studio itself is not required.
 
 ### Step 3- Running Flutter
 Type "flutter run" into the terminal. It will give you an option to run the application from your Windows desktop, from Google Chrome, or from Microsoft Edge. You can only run this application from the Windows desktop because the HC-05 bluetooth module is setup to interact through the COM port, but the web platforms do not support this. Ironically, Chrome and Edge are still required to be installed in order to run the application.



### Thank You For Trying Out Our App
