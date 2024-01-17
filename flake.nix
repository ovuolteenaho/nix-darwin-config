{
  description = "Example Darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      environment = {
        shells = [
          pkgs.fish
        ];
        systemPackages = [ 
          pkgs.android-tools
          pkgs.bat
          pkgs.coreutils
          pkgs.curl
          pkgs.direnv
          pkgs.git
          pkgs.git-lfs
          pkgs.lsd
          pkgs.neovim
          pkgs.openfortivpn
          pkgs.openjdk17
          pkgs.python3
          pkgs.rectangle
          pkgs.ripgrep
          pkgs.timidity
          pkgs.vim
          pkgs.wget
        ];
        variables = {
          JAVA_HOME = "${pkgs.openjdk17.home}";
          ANDROID_SDK_ROOT = "/Users/ollivuolteenaho/Library/Android/sdk";
          ANDROID_NDK_ROOT = "/Users/ollivuolteenaho/Library/Android/sdk/ndk/25.1.8937393";
          CMAKE_ROOT = "/Users/ollivuolteenaho/Qt/Tools/CMake/Cmake.app/Contents/bin";
          NINJA_ROOT = "/Users/ollivuolteenaho/Qt/Tools/Ninja";
        };
      };

      homebrew = {
        enable = true;
        casks = [
          "android-studio"
          "firefox"
          "kitty"
          "microsoft-outlook"
          "microsoft-teams"
          "orion"
        ];
        global.autoUpdate = false;
        onActivation = {
          autoUpdate = true;
          cleanup = "zap";
          upgrade = true;
        };
      };

      launchd.user.envVariables = {
        JAVA_HOME = "${pkgs.openjdk17.home}";
        ANDROID_SDK_ROOT = "/Users/ollivuolteenaho/Library/Android/sdk";
        ANDROID_NDK_ROOT = "/Users/ollivuolteenaho/Library/Android/sdk/ndk/25.1.8937393";
        CMAKE_ROOT = "/Users/ollivuolteenaho/Qt/Tools/CMake/Cmake.app/Contents/bin";
        NINJA_ROOT = "/Users/ollivuolteenaho/Qt/Tools/Ninja";
      };

      programs.fish = {
        enable = true;
        shellAliases = {
          ls = "lsd";
          vim = "nvim";
        };
      };

      system.defaults = {
        dock = {
          autohide = true;
          magnification = false;
          mru-spaces = false;
          orientation = "bottom";
          show-recents = false;
          static-only = true;
        };
        finder = {
          AppleShowAllExtensions = true;
          AppleShowAllFiles = true;
          FXDefaultSearchScope = "SCcf";
          ShowPathbar = true;
          ShowStatusBar = true;
        };
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPassword = true;
        screensaver.askForPasswordDelay = 10;
      };

      # Auto upgrade nix package and the daemon service.
      services.nix-daemon.enable = true;
      # nix.package = pkgs.nix;

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 4;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#QT-L-K0HG663WJR
    darwinConfigurations."QT-L-K0HG663WJR" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."QT-L-K0HG663WJR".pkgs;
  };
}
