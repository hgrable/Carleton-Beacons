# Carleton-Beacons Technical Readme

## Basic structure of the app

The main screen of the app is a simple table that lists all of the beacons currently in range of the device. It is controlled by `BeaconTableViewController`, which is a `UIViewController` that contains nothing but a `UITableView` object named `tableView`. This, in turn, holds cells representing beacons. The cells have a custom designed implemented in `Main.storyboard`, with `titleLabel`, `subtitleLabel`, and `imageView` objects identified with tags.

Each table cell displays information that it gets from reading a `BeaconInfo` object. This class is defined in `BeaconInfo.swift`, and it's basically a glorified dictionary. Currently it stores titles, subtitles, images, and links to detail websites. Each beacon is identified by its "minor" value, a random unsigned integer. The detail website for each beacon is displayed in a simple `UIWebView`.

These beacon attributes are downloaded from a JSON file that is hosted on a server, currently the `webpub` directory in my HOME drive. Pointing the app to a different location for the JSON is a one-line change in `BeaconTableViewController.swift`. Similarly, changing the websites that are displayed for each beacon is also quite simple. All you need to do is change the `url` field of the `beacons.json` file to the new website. Images can be hosted anywhere, but by default the app looks for them in the `images` subdirectory of the directory that `beacons.json` is located in. A sample backend configuration is included in the `backend` directory of this repository.

## Beacon details

The app has two main interactions with beacons. Most importantly, in `BeaconTableViewController.swift`, a `CLBeaconRegion` called `beaconRegion` is defined and passed to the `beaconManager` function, telling the app to look only for beacons with a specific UUID and major value (a major value is another unsigned integer like a minor value). This region can be defined with just a UUID, or a combination of UUID and major value or UUID and major and minor value. The `identifier` parameter is just an internal value that would be used to distinguish between multiple `CLBeaconRegion`s. The `beaconManager` function helpfully provides an array of beacons called `beacons` that is ordered in descending order of **approximate** proximity. This is where a lot of the logic of the app happens. When a beacon is detected, the app looks up its corresponding `BeaconInfo` object using its minor key, `beacon.minor`, stores it in an array of `BeaconInfo` objects that the `UITableView` can see, and then refreshes the `UITableView`.

The other interaction the app has with beacons is defined in `AppDelegate.swift`. Here, another `CLBeaconRegion` is defined, identically to the first one. This one, however, is used to scan for beacons in the background even when the app is quit. When a beacon is found, iOS will display a small contextual notification to the user, putting the app icon in the bottom left corner of the lock screen. This "monitoring" uses much less power than the "ranging" that happens when the app is active. In `AppDelegate`'s `beaconManager` function, you have the option to display an explicit notification to the user when a beacon is found. This code is commented out for the moment.

If you ever need to transfer ownership of beacons to another Estimote account, there are a few things that you need to change:

* The UUID of each beacon will be reset upon transfer, so you will either need to change the UUIDs back to what they were before, or generate a new UUID and change the UUID that the app is looking for. Remember, there are two separate `CLBeaconRegions`: one in `BeaconTableViewController.swift` and one in `AppDelegate.swift`.

* The `AppID` and `AppToken` parameters in the `ESTConfig.setupAppID()` function called in the `application` function in `AppDelegate.swift` will need to be changed. You can make appropriate values by logging onto [Estimote Cloud](https://cloud.estimote.com) and configuring a new app there.
