# HaSuRiski
Predictive map of Acid Suflate soils updating in real time with new labels.

This app displays the predicted map of acid sulfate soils along the southern and western coasts of Finland. 
Two predictions are displayed:
- manually drawn predicted map from GTK
- predicted map developed in HaSuRiski project

In addition, there is a Live map that computes the predicted map on-the-fly, right on the device. 
It accepts new measurement points and updates its map in real time. Other maps don't change with new data points.

## Dependencies
This project depends on [Cache](https://github.com/hyperoslo/Cache) package, that itself needs [Semaphore](https://github.com/groue/Semaphore) package. 
Clone both to the same folder with the HaSiRiski project.

This project depends on map tiles to work properly. The tile archives are stored at [GDrive of Arcada UAS](https://drive.google.com/drive/folders/1Z5s8reE-NGNpIQRQAfAsfi4INuqz5mQf?usp=sharing). 
Ask for access individually.

## Installation
The app is compiled and installed with XCode. It requires an iPhone with iOS 17 or newer, but may work on an iPad. You would also need a Mac computer to run XCode.
You would need basic experience with XCode app writing, at least to set your own account (it is free but needs configuration). 

The device needs a developer mode enabled, and trust the custom developer certificate - follow on-screen instructions during the first installation.

The app needs local map files. Start by downloading and extracting .zip archives from Google Drive. Note that some of them are very large, 
especially the "full resolution" data at zoom levels 13, 14, 15 unzip to sizes 40GB, 150GB, 570GB. Highly suggested to use SSD storage because of a huge number of small files in map tiles.

Upload files to iPhone/iPad by connecting the device to a Mac (that you already did for an app installation), opening its "Files" storage in Finder, then drag-and-dropping the folders with files. This **will** take a while, up to several hours.
<img width="886" alt="image" src="https://github.com/akusok/HaSuRiski/assets/2631546/5495bb7c-4500-45cc-8788-1f80f0100f3c">

The folders are:
- `hasuriski_ennako` for GTK predictions
- `predict_terrain` for HaSuRiski fixed predictions
- open folder "hasuriski_data_subsampled_2" and drag folders `2`, `3`, `4`, ... to the app to enable Live model predictions

The number represents zoom level, higher number for more detailed map. You can stop early, e.g. at level 9, to save space on device and reduce transfer time. 
Inside the app, zooming too closely makes the map disappear but nothing breaks.

You can also leave only part of map tiles around the area of interest at high zoom levels, to save space but have a detailed map where you need it. 
Find more info on working with tiles on [Slippy map tilenames](https://wiki.openstreetmap.org/wiki/Slippy_map_tilenames) page.

### App stops working after update
The app may stop working after iOS update. Reinstall it from XCode to fix the problem. Uploaded data will stay on the device.

### Delete data to free up iPhone storage
You can remove uploaded data in the same "Files" window in Finder, or by deleting the app on iPhone/iPad.

### Use different detail level in Live maps
Live maps are available in full resolution (largest), subsample 2 (2x2 averaged pixels), and subsample 4 (4x4 averaged pixels). To switch the resolution, 
you should upload folders `2`, `3`, `4`, ... up to `15` from a corresponding folder to your phone.  
You **must** also change `subsample` parameter in code in `Model/CachedOverlay.swift` source file to the correct value: 1, 2, or 4. 

Default subsample value is 2.

