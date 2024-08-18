# Web Content Tracking

@Metadata {
    @PageColor(green)
}

Correctly track web content displayed by your app.

## Overview

Apps might display or embed web content in various ways, whether this content is part of the SRG SSR offering or external to the company (e.g. some arbitrary YouTube page).

SRG SSR websites must themselves implement page view tracking in JavaScript, so that usage data can be properly collected when a browser (desktop or mobile Safari, Chrome, Edge, etc.) is used to navigate them. External websites, while not tracked themselves by the SRG SSR, most of the time provide a (possibly convoluted) way to navigate to an SRG SSR website by following some series of hyperlinks.

> Important: To comply with Mediapulse guidelines it is especially important that no tracked SRG SSR web content is displayed while a tracked app is running in the foreground. The reason is that two separate analytics sessions would then coexist for native and web content with overlapping measurements (e.g. session duration), which is strictly forbidden by Mediapulse.

Ensuring that web content is correctly tracked in your app requires a few precautions discussed in this article.

### Glossary

In the following we refer to the various ways of displaying web content as follows:

- Web view: Component which an app can use to embed web content in a flexible way ([`WKWebView`](https://developer.apple.com/documentation/webkit/wkwebview)).
- In-app web browser: Web browser interface which can be used to display web content without leaving an app ([`SFSafariViewController`](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller)).
- Device browser: Any standalone browser app that can be used on a device (e.g. Safari Mobile, Google Chrome, etc.). To invoke the default web browser use the [`open(_:options:completionHandler:)`](https://developer.apple.com/documentation/uikit/uiapplication/1648685-open) method, which also provides support for deep linking.

### Use the device browser

Most of the time it is very difficult or nearly impossible to guarantee that, starting from some random web page (part of SRG SSR offering or not) you cannot somehow reach a tracked SRG SSR web page. For example, even if your app opens a Wikipedia page about some random topic, it is always possible that the user can search for an SRG SSR article and finally reach one of our tracked websites.

In such cases you should present the web content with the device browser. This ensures your app is automatically sent to the background so that Mediapulse requirements are guaranteed to be fulfilled, no matter how the user navigates the web content.

This approach works well for apps which present loosely related web content, for example a link to some article, to a user guide or to legal information pages.

#### Use cases

- Mostly native application with documentation accessible via web pages.
- Player application offering a few links to articles related to content being played.

### Display web content in app

Your app might need to display web content with tight integration into its native user interface. In such cases you must consider the web view or in-app browser approaches.

If the web content you want to display belongs to the SRG SSR, it must provide a way to disable JavaScript tracking entirely **for the first loaded web page** (e.g. with a special resource path or parameter) so that it can be displayed while your application is in foreground without overlapping measurements.

Note that only the first web navigation level is affected by this rule. As it is impossible to avoid reaching an SRG SSR web page starting from a random web page, Mediapulse namely agreed that levels deeper than the first one are allowed to be tracked.

#### Use cases

- News application displaying articles from the companion website as HTML.
- Login web page displayed using [Authentication Services](https://developer.apple.com/documentation/authenticationservices), which itself uses the in-app browser for presentation.
