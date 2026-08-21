# Free GitHub APK Build

This project is configured to build the Android APK using **GitHub Actions**. You do not need Flutter or Android Studio installed on your computer for the GitHub build.

## 1. Create the repository

1. Sign in to GitHub.
2. Create a new repository, for example `sik_hotel_billing`.
3. Upload all files from this project to the repository.
4. Commit the files to `main`.

## 2. Start the build

Open:

`GitHub repository → Actions → Build Android APK → Run workflow`

A push to `main` or `master` also starts the workflow automatically.

## 3. Download the APK

After the workflow finishes:

`Actions → Build Android APK → latest successful run → Artifacts → sik-hotel-billing-apk`

Download the ZIP artifact and extract:

`sik-hotel-billing-release.apk`

## 4. What the workflow does

- Installs the current Flutter stable SDK on GitHub's Ubuntu runner.
- Generates the missing Android platform files with `flutter create`.
- Applies the Bluetooth and legacy storage manifest permissions from the original project requirements.
- Runs `flutter pub get`.
- Runs `flutter analyze` as a non-blocking quality check.
- Builds a release APK.
- Uploads the APK as a GitHub Actions artifact.

## 5. Important: release signing

The generated release APK is **not Play Store-signed with a private production keystore**. It is intended for direct installation/testing and can be built without storing a signing secret in GitHub.

For Google Play publishing, create a private upload/release keystore and configure GitHub Actions secrets. Never commit a `.jks`, `.keystore`, or `key.properties` file to the repository.

## 6. Default login

Username: `admin`

Password: `admin123`

Change the password immediately after first login.


## Build fix applied

- Updated `file_picker` to 8.3.7 to remove the old Flutter v1 Android embedding references that break modern Flutter release builds.
- Removed the empty `assets/` declaration because the project currently contains no tracked asset files.
