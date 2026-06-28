{
  description = "CronogramaActividades - Flutter + Angular + Firebase dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
          config.android_sdk.accept_license = true;
        };

        android-sdk = pkgs.androidenv.composeAndroidPackages {
          cmdLineToolsVersion = "13.0";
          toolsVersion = "26.1.1";
          platformToolsVersion = "37.0.0";
          buildToolsVersions = [ "28.0.3" "34.0.0" "35.0.0" "36.0.0" ];
          platformVersions = [ "34" "35" "36" ];
          includeEmulator = true;
          includeSystemImages = true;
          systemImageTypes = [ "google_apis_playstore" ];
          abiVersions = [ "x86_64" ];
          includeNDK = true;
          ndkVersions = [ "28.2.13676358" ];
          useGoogleAPIs = false;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          name = "cronograma-actividades";

          packages = with pkgs; [
            # Flutter & Dart
            flutter
            dart

            # Android SDK (configured via androidenv)
            android-sdk.androidsdk
            
            # Chrome (for Flutter Web)
            google-chrome

            # Node.js ecosystem (Angular CLI)
            # npm is bundled with nodejs — no separate package needed
            nodejs_24

            # Firebase CLI (from nixpkgs — reproducible, no npm global install needed)
            firebase-tools

            # Angular CLI (installed via npm in shellHook)

            # JDK (required for Flutter Android builds)
            jdk17

            # Git
            git

            # Utilities
            curl
            which
            unzip
          ];

          shellHook = ''
            export NPM_CONFIG_PREFIX="$HOME/.npm-global"
            export PATH="$NPM_CONFIG_PREFIX/bin:$HOME/.pub-cache/bin:$PATH"

            echo "🚀 CronogramaActividades Dev Environment"
            echo "  Flutter:  $(flutter --version 2>/dev/null | head -1 || echo 'not found')"
            echo "  Node:     $(node --version)"
            echo "  npm:      $(npm --version)"

            # Install Angular CLI globally if not present
            if ! command -v ng &>/dev/null; then
              echo "  📦 Installing Angular CLI..."
              npm install -g @angular/cli@latest
            fi

            export JAVA_HOME="${pkgs.jdk17}"
            export ANDROID_HOME="${android-sdk.androidsdk}/libexec/android-sdk"
            export ANDROID_SDK_ROOT="${android-sdk.androidsdk}/libexec/android-sdk"
            export CHROME_EXECUTABLE="${pkgs.google-chrome}/bin/google-chrome-stable"
            
            # To fix 'eglinfo' warning for linux builds
            export LD_LIBRARY_PATH="${pkgs.libGL}/lib:$LD_LIBRARY_PATH"

            # Fix AAPT2 for NixOS: Gradle downloads a dynamically linked aapt2 that
            # cannot run on NixOS. Override it with the one from the Nix Android SDK.
            AAPT2_PATH=$(find -L "${android-sdk.androidsdk}/libexec/android-sdk/build-tools" -name "aapt2" 2>/dev/null | sort -V | tail -1)

            # Fix cmake.dir in flutter_app/android/local.properties to use the Nix SDK cmake.
            CMAKE_DIR=$(find -L "${android-sdk.androidsdk}/libexec/android-sdk/cmake" -maxdepth 1 -mindepth 1 -type d 2>/dev/null | sort -V | tail -1)
            LOCAL_PROPS="$PWD/android/local.properties"
            if [ -n "$CMAKE_DIR" ] && [ -f "$LOCAL_PROPS" ]; then
              if grep -q "cmake.dir" "$LOCAL_PROPS" 2>/dev/null; then
                sed -i "s|cmake.dir=.*|cmake.dir=$CMAKE_DIR|" "$LOCAL_PROPS"
              else
                sed -i "/sdk.dir=/a cmake.dir=$CMAKE_DIR" "$LOCAL_PROPS"
              fi
            fi
            if [ -n "$AAPT2_PATH" ]; then
              mkdir -p "$HOME/.gradle"
              GRADLE_PROPS="$HOME/.gradle/gradle.properties"
              if grep -q "android.aapt2FromMavenOverride" "$GRADLE_PROPS" 2>/dev/null; then
                sed -i "s|android.aapt2FromMavenOverride=.*|android.aapt2FromMavenOverride=$AAPT2_PATH|" "$GRADLE_PROPS"
              else
                echo "android.aapt2FromMavenOverride=$AAPT2_PATH" >> "$GRADLE_PROPS"
              fi
              echo "  ✅ AAPT2 override set to: $AAPT2_PATH"
            else
              echo "  ⚠️  Could not find aapt2 in Android SDK build-tools."
            fi

            echo ""
            echo "  Run 'flutter doctor' to check Flutter setup."
            echo "  Run 'firebase login' to authenticate Firebase CLI."
          '';
        };
      });
}
