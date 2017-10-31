# iOS-PWA-Wrapper

An iOS Wrapper application to create a native iOS App from an offline-capable Progressive Web App.

Drafted for the future iOS App of my [Leasing Calculator](https://www.leasingrechnen.at) Web App using [React](https://github.com/facebook/react), [Redux](https://github.com/reactjs/redux), [Materialize.css](https://github.com/Dogfalo/materialize) and a lot of Offline-First love over at [leasingrechnen.at](https://www.leasingrechnen.at).

For bringing offline-capabilities to your Web App on Safari and iOS' embedded WebKit browser, you have to use [AppCache](https://developer.mozilla.org/en-US/docs/Web/HTML/Using_the_application_cache). [Service Worker API](https://developer.mozilla.org/en-US/docs/Web/API/Service_Worker_API) is not yet supported in WebKit, so you might want to use something like [Appcache Webpack Plugin](https://github.com/lettertwo/appcache-webpack-plugin) to make your PWA offline-accessible on iOS in a somewhat easy way.

### Under development, don't use for your apps yet. First Release coming soon!

## Why would I use a wrapper?
I know, using a Wrapper-App to display a Website can feel a bit odd. But there are a few good reasons why you'd package your Web App like this.
- If you've got a very sophisticated UI already, it might make sense not to rebuild it from scratch for multiple platforms, especally if it's a Single Page Application already, that doesn't "feel" like a Website.
- There might be as well less competition for a given niche on App Stores, in comparison to Google directly. With [leasingrechnen.at](https://www.leasingrechnen.at), I've got easily into the Top 10 Apps on Google Play for my country, whereas Google Search put me on page 9 as the Site is relatively new.

## What it does
- Provides a native iOS navigation header.
- Sets up a WKWebView instance just the way PWAs/SPAs like it.
- Provided your Web App is Offline-capable, it only needs an Internet connection on the first startup. If this fails, it shows a native refresh widget.
- Opens all external URLs in the device's Browser / 3rd party apps instead.
- Automatically fetches updates of your Web App.

## How to build your own
- Clone/fork repository and open in Xcode
- Head over to `Constants.swift` and
    - add your app's name and the main URL to fetch
    - set the host you want to restrict your app to
    - add your custom Javascript string to open your Web App's menu.
        - this is injected into the site when the "Menu" button is pressed. This wrapper assumes you're hiding your Web App's header in favor of the native App navigation and show/hide your menu via Javascript.
    - customize the colors
    - tweak the other options as you prefer
- Put your own App icons in place in `Assets.xcassets`
    - Remember, 1pt equals 1px on 1x-size. E.g., if you have to provide a 20pt icon of 3x-size, it has to be 60x60px.
    - iOS doesn't like transparency, use background colors on your icons.
    - I like using [App Icon Maker](http://appiconmaker.co), but any other similar service will do it as well.
    - Don't forget the `launcher` icon!
- Change _Bundle Identifier_ and _Display Name_
- Build App in Xcode

### I don't accept Feature Requests, only Pull Requests :)

## License
[GNU General Public License v3.0](https://www.gnu.org/licenses/gpl-3.0.en.html) - if you use it, we wanna see it!
