{
  description = "Flutter template";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils = {
      url = "github:numtide/flake-utils";
    };
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    flake-compat,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        jdkVersions = ["17" "11" "8"];
        pkgs = import nixpkgs {
          system = system;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };
        buildToolVersion = "34.0.0";
        androidComposition = pkgs.androidenv.composeAndroidPackages {
          cmdLineToolsVersion = "13.0";
          toolsVersion = "26.1.1";
          platformToolsVersion = "35.0.1";
          buildToolsVersions = ["30.0.3" buildToolVersion];
          includeEmulator = false;
          emulatorVersion = "35.1.4";
          platformVersions = ["34"];
          includeSources = false;
          #includeSystemImages = false;
          # systemImageTypes = [ "google_apis_playstore" ];
          abiVersions = ["x86_64" "armeabi-v7a" "arm64-v8a"];
          #cmakeVersions = [ "3.10.2" ];
          #includeNDK = true;
          #ndkVersions = [ "22.0.7026061" ];
          #useGoogleAPIs = false;
          #useGoogleTVAddOns = false;
          #includeExtras = [
          #  "extras;google;gcm"
          #];
        };
        jdks = map (version: pkgs."temurin-bin-${version}") jdkVersions;
        flutter = pkgs.flutter322;
        androidSdk = "${androidComposition.androidsdk}";
        androidHome = "${androidSdk}/libexec/android-sdk";
        jdkPaths = builtins.concatStringsSep "," jdks;
        gradleOpts = [
          "-Dorg.gradle.project.android.aapt2FromMavenOverride=${androidHome}/build-tools/${buildToolVersion}/aapt2"
          "-Dorg.gradle.project.org.gradle.java.installations.auto-detect=false"
          "-Dorg.gradle.project.org.gradle.java.installations.auto-download=false"
          "-Dorg.gradle.project.org.gradle.java.installations.paths=${jdkPaths}"
        ];
      in {
        devShells = {
          default = pkgs.mkShell {
            name = "Flutter devshell";
            buildInputs =
              jdks
              ++ [
                androidSdk
                flutter
              ];
            JAVA_HOME = "${builtins.head jdks}";
            ANDROID_HOME = "${androidHome}";
            FLUTTER_ROOT = "${flutter}";
            GRADLE_OPTS = "${builtins.concatStringsSep " " gradleOpts}";
          };
        };
      }
    );
}
