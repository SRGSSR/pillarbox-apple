# Web Content Tracking

@Metadata {
    @PageColor(green)
}

Ensure accurate tracking of web content displayed by your app.

## Overview

Apps may display or embed web content in various ways, whether it’s part of the SRG SSR offering or external (e.g., an arbitrary YouTube page):

- **SRG SSR websites:** These implement page view tracking in JavaScript to collect usage data when accessed via web browsers.
- **External websites:** While not tracked by SRG SSR, these often provide indirect access to SRG SSR content through hyperlinks.

> Important: To comply with Mediapulse guidelines, no tracked SRG SSR web content should be displayed while a tracked app is running in the foreground. Doing so would result in two overlapping analytics sessions (for native and web content), which is strictly forbidden.

This article outlines the precautions necessary to ensure web content is tracked correctly in your app.

### Glossary

- **Web view:** An embeddable component for displaying web content directly within an app ([`WKWebView`](https://developer.apple.com/documentation/webkit/wkwebview)).
- **In-app web browser:** A browser-like interface for viewing web content without leaving the app ([`SFSafariViewController`](https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller)).
- **Device browser:** A standalone browser app (e.g., Safari, Chrome). Use [`open(_:options:completionHandler:)`](https://developer.apple.com/documentation/uikit/uiapplication/1648685-open) to open content in the default device browser, with support for deep linking.

### Use the device browser

In many cases, it’s challenging or impossible to ensure that navigating from an arbitrary web page won’t lead to a tracked SRG SSR web page. For example, a user might start on a Wikipedia page but eventually search for and access SRG SSR content.

In such scenarios, use the device browser to display web content. This approach automatically sends your app to the background, ensuring compliance with Mediapulse requirements regardless of user navigation.

This solution works well for apps displaying loosely related web content, such as links to articles, user guides, or legal information.

#### Use cases

- Native applications with documentation accessible via web pages.
- Player applications offering links to articles related to the content being played.

### Display web content in-app

In some cases, your app may need to tightly integrate web content into its native user interface. When doing so, consider using a **web view** or **in-app browser**.

If the displayed web content belongs to SRG SSR, ensure that JavaScript tracking is **disabled for the first loaded page** (e.g., using a special resource path or parameter). This prevents overlapping measurements while your app is in the foreground.

> Note: Only the **first level** of web navigation must adhere to this rule. Mediapulse allows tracking for deeper levels, as it’s impossible to fully control navigation starting from a random web page.

#### Use cases

- News apps displaying articles from a companion website as HTML.
- Login pages displayed using [Authentication Services](https://developer.apple.com/documentation/authenticationservices), which rely on in-app browsers for presentation.
