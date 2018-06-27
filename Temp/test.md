

I’ve developed a FrontCameraView UIView class for a project
that I’ve been working on. This project has allowed me the opportunity to study
Apple’s AVFoundation framework. According to Apple documentation:

The AVFoundation framework combines four major technology areas that together
encompass a wide range of tasks for capturing, processing, synthesizing,
controlling, importing and exporting audiovisual media on Apple platforms.

The main features of FrontCameraView class are:

* Preview front camera
* Move the preview UIView to every corner of the screen.
* Record video

### Configure camera and microphone permission

First of all, we need to ask the user for permission to use the camera and microphone. That’s why we
need to configure our Info.plist to include a message to the user. Include the NSCameraUsageDescription and
NSMicrophoneUsageDescription key in your app’s Info.plist file. For each key we
have to provide a message that explains to the user why our app nedds to
capture media.

This message will appear the first time we run the app
and usually the user accept it. But, what happens if the user has revoked this
permission? I think it’s a good idea to check if your app still has permission
to access the camera and microphone. If not, we could show a warning message to
the user about that and how to solve it.

With this line of code we will show the warning
message and, if the user press Settings button, we will show him the app’s configuration
panel to change it.

### Camera Manager

This class manage permissions, camera and microphone
access, camera configuration, preview and recording.

### FrontCameraView

This class show the camera preview and allows the user to move the view.



