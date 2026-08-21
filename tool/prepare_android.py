from pathlib import Path
import re

manifest = Path("android/app/src/main/AndroidManifest.xml")
if not manifest.exists():
    raise SystemExit(f"AndroidManifest.xml not found: {manifest}")

text = manifest.read_text(encoding="utf-8")

permissions = '''    <!-- Bluetooth printing permissions -->\n    <uses-permission android:name="android.permission.BLUETOOTH" android:maxSdkVersion="30" />\n    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" android:maxSdkVersion="30" />\n    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />\n    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />\n\n    <!-- Legacy shared-storage permissions for Android 9 and below -->\n    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="28" />\n    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32" />\n'''

if "android.permission.BLUETOOTH_CONNECT" not in text:
    text = text.replace("    <application", permissions + "\n    <application", 1)

# Keep the generated Flutter applicationName/icon attributes and add legacy storage compatibility.
if "android:requestLegacyExternalStorage=" not in text:
    text = text.replace(
        'android:icon="@mipmap/ic_launcher">',
        'android:icon="@mipmap/ic_launcher"\n        android:requestLegacyExternalStorage="true">',
        1,
    )

# The app is designed to work offline. Do not add INTERNET permission here.
text = re.sub(r"^\s*<uses-permission\s+android:name=[\"']android\.permission\.INTERNET[\"']\s*/>\s*$", "", text, flags=re.MULTILINE)

manifest.write_text(text, encoding="utf-8")
print(f"Prepared {manifest}")
