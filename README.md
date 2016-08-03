# Carleton Beacons App

Carleton Beacons is a universal iOS app that leverages Bluetooth beacons located around the Carleton College campus to provide contextual information about various exhibits and landmarks. It uses the Estimote SDK for iOS to communicate with Estimote beacons attached to each exhibit.

## Usage

Clone this repository, open up `Carleton-Beacons.xcworkspace`, connect your iDevice to your computer, and run the app on your iDevice.

## Use of Location Services

One of the first thing that happens when you launch this app is a prompt that asks you to allow the app to use Location Services. Don't worry though; it won't drain your battery because it doesn't use GPS at all. Low energy Bluetooth beacon technology falls under the broad Location Services umbrella, so in order for this app to be able to do anything, it must have access to Location Services (and Bluetooth must be turned on).
