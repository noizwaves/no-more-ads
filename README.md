# No More Ads

Ad blocker extension for Chrome, optimised for improving the viewing experience of the [Daily Camera](https://www.dailycamera.com)

## Dependencies

-  [Elm 0.19](https://github.com/elm/compiler/releases/tag/0.19.0) installed and available in PATH
-  [`elm-format` 0.8.1](https://github.com/avh4/elm-format/releases/tag/0.8.1) installed and available in PATH
-  [StevenBlack's hosts file](https://github.com/StevenBlack/hosts/blob/master/data/StevenBlack/hosts)

## Getting Started

1.  `wget -o blocklists/hosts https://github.com/StevenBlack/hosts/blob/master/data/StevenBlack/hosts`
1.  `cd app` and run `./build.sh`
1.  Load `./manifest.json` as an [unpacked extension](https://developer.chrome.com/extensions/getstarted#manifest) in Chrome
1.  Visit [Daily Camera](https://www.dailycamera.com)