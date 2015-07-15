---
title: Building mobile apps with Meteor and Cordova
layout: post
date: 2015-05-22
---

![Meteorites]({{ site.url }}/images/posts/meteor/meteoriten.png "Meteorites")

# Meteor: meet Cordova
I first was introduced to Meteor through a [Railscast](http://railscasts.com/episodes/351-a-look-at-meteor) back in 2012 when I was still doing a lot of rails development. Back then I dabbled a bit with it but never really gave it much attention. When Meteor was back at [#1 of HN](https://news.ycombinator.com/item?id=9300349) some weeks ago I decided it was time to give it another shot and play a bit with it.

It seemed that Meteor really grew up and gained a serious following over the years. At the time of this writing, [Meteor is the #10 most starred project on Github](https://github.com/search?q=stars:%3E1&s=stars&type=Repositories). It now works on Mac, Linux and Windows and it takes away a lot of overhead from your development, as it sets up your MongoDB database and real-time communication through websockets automatically for you. Being completly reactive, that means that your frontend will automatically update and reflect and changes to the displayed data on all clients by default.
Go ahead and checkout the excellent [Meteor website](https://www.meteor.com/) to learn more about what Meteor is and what it can do for you.

Meteor also recently added support to develop Cordova apps with it. Well, [no so recently](http://info.meteor.com/blog/meteor-092-iOS-Android-mobile-apps-phonegap-cordova). The Meteor wiki firmly describes
[the steps needed to add the Cordova platform to your Meteor app](https://github.com/meteor/meteor/wiki/Meteor-Cordova-Phonegap-integration).

## A simple list App

So let's kick things of with a simple list app. Make sure you have Meteor installed, the recommended way to that is `curl https://install.meteor.com/ | sh`.

<blockquote class="twitter-tweet" lang="en"><p lang="en" dir="ltr">you&#39;re acting pretty confident for somebody who just curled something from the internet and piped it to bash.</p>&mdash; Sad Server (@sadserver) <a href="https://twitter.com/sadserver/status/529397101705166848">3. November 2014</a></blockquote>
<script async src="//platform.twitter.com/widgets.js" charset="utf-8"></script>

Now with Meteor installed, we can start a new app with the `meteor create <app name>` command. Our App is called listy, so let's do `meteor create listy`, then `cd listy` and `meteor` to start the local development server. You app is now running at `localhost:3000` and presents you with a little Click Me button.



