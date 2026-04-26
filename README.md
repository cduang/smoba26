# TrollSpeed

[![Xcode - Build and Analyze](https://github.com/Lessica/TrollSpeed/actions/workflows/build-analyse.yml/badge.svg)](https://github.com/Lessica/TrollSpeed/actions/workflows/build-analyse.yml)
[![Analyse Commands](https://github.com/Lessica/TrollSpeed/actions/workflows/analyse-commands.yml/badge.svg)](https://github.com/Lessica/TrollSpeed/actions/workflows/analyse-commands.yml)
[![Build Release](https://github.com/Lessica/TrollSpeed/actions/workflows/build-release.yml/badge.svg)](https://github.com/Lessica/TrollSpeed/actions/workflows/build-release.yml)
![Latest Release](https://img.shields.io/github/v/release/Lessica/TrollSpeed)
![MIT License](https://img.shields.io/github/license/Lessica/TrollSpeed)

Shows upload &amp; download speed below the status bar.

Tested and expected to work on all iOS versions supported by opa334’s TrollStore.

You need to enable “Developer Mode” on iOS 16 or above to use TrollSpeed or Misaka.

## How it works?

[TrollStore](https://github.com/opa334/TrollStore) + [UIDaemon](https://github.com/limneos/UIDaemon) + [NetworkSpeed13](https://github.com/lwlsw/NetworkSpeed13) + (some magic)
\=

- An TrollStore app to spawn HUD process with root privilege.
- Don’t call `waitpid` to that process. Let it go.
- A HUD app with entitlements from `assistivetouchd` to display and persist global windows.

## How to build?

- Use [theos](https://github.com/theos/theos) to compile.
  - `FINALPACKAGE=1 make package`
- You'll get a `.tipa` file in `./packages` folder.
- Don't like **theos**? Use `./build.sh` to build with Xcode.
- You can also use GitHub Actions to build automatically and upload the `.tipa` artifact.
- If the workflow is triggered by a tag like `v1.0.0`, it will also create a GitHub Release and attach the build artifact.
- Or let GitHub Actions build it for you with the workflow in `.github/workflows/build.yml`.

## Caveats

- Spawn with root privileges is **required**. Otherwise, the HUD process will be killed by SpringBoard when unlocking device.
- TrollSpeed will observe its app removal and terminate its HUD.

## Notes

- Please give me feedback if you find any issues &amp; bugs, or have any suggestions.
- Give me a star 🌟 if you like this project. Thanks!

## Screenshots

![preview](screenshots/preview.jpeg)

## Special Thanks

- [KIF](https://github.com/kif-framework/KIF)
- [SPLarkController](https://github.com/ivanvorobei/SPLarkController) by [@ivanvorobei_](https://twitter.com/ivanvorobei_)
- [TrollStore](https://github.com/opa334/TrollStore) by [@opa334dev](https://twitter.com/opa334dev)
- [UIDaemon](https://github.com/limneos/UIDaemon) by [@limneos](https://twitter.com/limneos)
- [NetworkSpeed13](https://github.com/lwlsw/NetworkSpeed13) by [@johnzarodev](https://twitter.com/johnzarodev)
- [SnapshotSafeView](https://github.com/Stampoo/SnapshotSafeView) by [Ilya knyazkov](https://github.com/Stampoo)

## License

TrollSpeed is [Free Software](https://www.gnu.org/philosophy/free-sw.html) licensed under the [GNU General Public License](LICENSE).

### Localization

To add a language, create a new `.lproj` folder in `layout/Applications/TrollSpeed.app`.

- en/zh-Hans [@Lessica](https://github.com/Lessica)
- es [@Deci8BelioS](https://github.com/Deci8BelioS)
