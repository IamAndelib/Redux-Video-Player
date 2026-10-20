# Transcript: "I Redesigned VLC After 25 Years" by Juxtopposed

- Video: https://youtu.be/ERFeOgqk324 (20:30). Figma: https://www.figma.com/design/CAuJVJyM5yY7PnyQQK9X24/VLC-Redesign--Community-
- **Use [`brief.md`](brief.md) for design work.** This file is the citable source behind it: the full narration, cleaned up.
- Cleanup applied to the Whisper `medium` output (`redux/tools/transcriber/transcribe.sh`):
  - Misheard words fixed ("ELC/DLC/BLC" → VLC, "codex" → codecs, "cue" → queue, "Mobben" → Mobbin).
  - Uncertain words are marked `[?]`, and editorial notes are in `[brackets]`.
  - Lines spoken by the test show in the demo are in *italics*.
  - The sponsor segment is reduced to one line.
- Section headings link to the moment in the video. Times are where each topic starts.

## Contents
1. [Intro and visual identity](#1-intro-and-visual-identity-0000)
2. [Control bar](#2-control-bar-0125)
3. [Top bar and fullscreen](#3-top-bar-and-fullscreen-0337)
4. [Track buttons and menus](#4-track-buttons-and-menus-0403)
5. [Subtitles workflow and the right sidebar](#5-subtitles-workflow-and-the-right-sidebar-0525)
6. [Queue and library](#6-queue-and-library-0912)
7. [Music](#7-music-1200)
8. [Network streams and the Open dialogs](#8-network-streams-and-the-open-dialogs-1222)
9. [Playlists, pins, Recent, Home and resume](#9-playlists-pins-recent-home-and-resume-1310)
10. [Sponsor](#10-sponsor-1403)
11. [Bookmarks, chapters and on-screen messages](#11-bookmarks-chapters-and-on-screen-messages-1450)
12. [Settings](#12-settings-1527)
13. [Customization and profiles](#13-customization-and-profiles-1855)
14. [Onboarding and outro](#14-onboarding-and-outro-1938)

## 1. Intro and visual identity ([00:00](https://youtu.be/ERFeOgqk324?t=0))
VLC, the go-to media player that can play almost any media file on any OS. We love VLC for a lot of reasons, but the UI is not one of them. A lot of people say it's old, but I don't think that's a bad thing, because VLC has far worse UI issues. I've been using VLC for a thousand years now, so I decided to try and redesign the UI. I asked you guys about your preferences and issues, and asked the VLC creator for the top design priorities. He was incredibly nice and helpful. He also tried to warn me, to which I said I'd love to try. Oh, if only I knew how bad things really are.

VLC's design is simple, and we're gonna keep it simple. Starting with the colors: the VLC logo is an orange traffic cone, because the creator had a traffic cone collection. I got a lot of messages saying keep the traffic cone. I mean, why wouldn't I? Apparently some people don't like it. That's interesting, but I'm gonna keep the cone and the orange color. We need some neutral gray and black colors for the background, and that's pretty much it.

For the icons, I noticed VLC uses these detailed two-tone icons with gray and orange. I'm gonna keep that style but modernize it and make them all consistent. I'll use these for the menus, where the icon isn't clickable, and another monochrome set for everywhere else.

Finally, we have the round versus sharp argument. Right now VLC is pretty sharp and rectangular, and most other media players are not. I think that gives VLC the personality it has; I just can't make it circular. So I'm gonna keep things rectangular, but a little less sharp, keeping VLC's unique visual identity.

## 2. Control bar ([01:25](https://youtu.be/ERFeOgqk324?t=85))
Let's be honest, most of us just want to click on a video, have it play, chill, and hope that the UI will be a quiet little bar that just does its job. But in VLC, it's quiet and kinda useless. So let's rebuild this.

First off, let's move the play button to the center. Nuh-uh. I know every player right now is like that. Even VLC is working on a redesign where the play button is in the center. But that makes VLC less unique, causes the control bar to be massive, covering a huge chunk of the video, and the majority of you guys just use the keyboard or some other shortcut to play and pause. It's kinda like YouTube. So let's keep it here, but make it a tiny bit bigger and move the next and previous icons around it.

Then we have the fullscreen icon here for some reason. On most players, Fullscreen or Settings icons are actually on the right side, so let's move them there.

Then we have Toggle Playlist. A singular playlist? What? "Oh, you mean a queue?" No, that's a playlist. "Yeah, but you say enqueue." Well, yes, but I also say add to playlist or save playlist to file. We need a **queue** that plays things automatically **and playlists** that are just your collections of media. For now, I'm gonna turn this icon into a queue icon and put these on the right side. Ideally, you just drag files into the queue, or use these icons to add whatever file you want to it. It's really simple.

On the right side we also have a volume slider. This is a cool design, and I don't want to oversimplify it like modern players do. I want to keep the spirit. If you think about it, this looks like a deformed cone, so let's make it a full cone, and of course keep the colors.

Finally, the seek bar. I don't know why every modern player has a thin, tiny slider. In a controversial move, I'm gonna put the seek bar down here and make it a lot thicker. Just trust the process. Now we can clean the whole thing up a bit and make a thin row that doesn't disrupt the video. Also, notice how VLC doesn't show a thumbnail as you seek through the video? That could be a nice feature to add.

## 3. Top bar and fullscreen ([03:37](https://youtu.be/ERFeOgqk324?t=217))
On the top we have a menu, the media title and window decorations. I'm gonna update it with our new style before talking about the details, like how it disappears in fullscreen. How are we supposed to see the title? Are we supposed to get out of fullscreen for something so simple? Most people look at the top area to find the title. So why not keep both the top and the bottom UI, and only show them when you hover near them, and have them immediately disappear when you move away? I also like the idea of putting the fullscreen icon, and maybe even a picture-in-picture icon, up here. That would be pretty simple to use. But tell me which one you prefer, up or down?

## 4. Track buttons and menus ([04:03](https://youtu.be/ERFeOgqk324?t=243))
We have the layout, but I can't wait to actually watch this. Wait, we need subtitles. At this point I just automatically right-click and go to Subtitle, then Subtitle Track. But that's way too much, and it's annoying when the menus keep closing. We can put a record button down here, but subtitles take multiple clicks. In the upcoming VLC design there's an icon that's supposed to show tracks, and it's on the left side. Once again, most people look for that on the bottom right. So let's put a **subtitle icon on the right** that opens a list of subtitle tracks. Right next to it we can have an **audio icon** that shows both audio tracks and **audio output**, like headphones or speakers, so you don't have to leave VLC for that. Finally, we can add one more tab for **video tracks**, but not an icon on the bar, because most of you never or rarely use it. If you want it, you've got both this and the right-click menu. We want to put things where we mostly need them.

The menus should be more efficient too. Look at these: the top menu is straight up the same as the right-click menu, just repeating the same things. So let's remove the extra and create **one menu icon** where we put these media-related options and extra settings. That's how it's going to look for now.

VLC is so bad at menus that it's normal to think, "if I want a setting, I should probably right-click the video." So the right-click menu is essential. I'll just clean it up, update it with our style, and add one option to **completely hide the UI** if you want. You could do that with a keyboard shortcut too.

## 5. Subtitles workflow and the right sidebar ([05:25](https://youtu.be/ERFeOgqk324?t=325))
This has all just been the tip of the iceberg, where you casually watch something and go about your day. From here on, we enter pro-gamer territory.

I'm trying to watch this show, but the subtitles kinda suck. So I gotta look online, download a zip, extract it into the same folder, and even then the file names don't match. Amazing. VLC does look for similar file names in the folder, but if I had a penny for every time I had to manually drag subtitle files into VLC for every episode, I could probably afford to upgrade my RAM right now. This has to be easier.

We have a new subtitle section. What if clicking **Add** opens a dialog with three options: add subtitles to **this file, this folder or this playlist**? Then another option to choose files **from this computer or from a website like OpenSubtitles**. This way you could add subtitles to entire folders, and they'd either get **automatically matched**, or you could **manually select the right subtitle file for every episode**, and it's saved for all future episodes.

Okay, this should be working, let's play. *"Evil, evil man, you'll pay for my lost aura."* Okay, something's off. The subtitle is a bit delayed; let's try fixing it. See this little icon I didn't address earlier? It's like Pandora's box. Half the settings you need while watching, including subtitle timing, live here, and somehow it has to cover half the screen. So you use it, close it, rewind the video, and do this ten times till they're synced. You can also press these keys on your keyboard, but that doesn't solve the main issue.

What if there was a **subtitle timeline** that showed the times the texts appear? You'd wait for the audio, pause the video, and just move the subtitles back. [?: Even if] you don't use keyboard shortcuts, this is still a problem.

We have subtitle tracks over here, so why not move all these preferences to the right and turn them into a **sidebar with four tabs**? First, **subtitles**. We need the three subtitle timing options, but imagine having to type, when it could be an easy **slider** instead. Then we need the subtitle **font, font size, outline and position**, so you can change them while watching. A lot of you said you wish VLC had exact font values, not small or big. And here's the thing: it does. It's just hidden deep inside Advanced Settings for some reason, and the settings are a whole different labyrinth we'll talk about later. So let's have two options, **Relative or Precise**, for sizes.

Now I've set my subtitle delay and formatting, but do I need to change it manually every single episode? Hell no. We should be able to save all these settings for this specific show through a **preset**, and later just select whatever preset you want and immediately bring the settings back.

Another thing I don't want to reselect every episode is the subtitle track. It's a binger's nightmare. If you have enough persistence, you end up searching for the solution, and it says go to Input / Codecs, deep in Advanced Settings. Input / Codecs? That's oddly irrelevant, considering subtitle settings are in a whole different place. How are we supposed to know this? I swear there should be a VLC expert certificate, because why do we have to put in so much effort just to set a default subtitle track? This could just be another simple setting in the sidebar, where you choose a **subtitle track or language to select automatically** on every episode, and it's saved in your preset.

The same applies to **audio**: default audio track, audio delay and so on. Then we have a bunch of **audio filters that can be expanded**, like the equalizer, which is for audio nerds, but a casual user can benefit from basic, friendly **presets with preview icons** next to them. Let's do the same for **video filters** too, because let's be honest, you need to **see a preview** of whatever you're doing. Flip, rotate, zoom, HDR, resolution, aspect ratio and similar settings can be here too. Finally, **playback** settings house the extras, like speed. Then we want a **reverse** feature, **sleep timer**, **show subtitle timeline**, **show waveform on the seek bar**, and finally **show metadata**.

## 6. Queue and library ([09:12](https://youtu.be/ERFeOgqk324?t=552))
Okay, let's continue watching. *"You'll never find the wand."* What? Oh my god, I gotta watch the next episode. Why doesn't it work? Ah, my bad for not adding the whole thing to the queue. Either way, there's gotta be an easier way to do this. "Um, actually, there is. You can go to the file browser, find your videos and add them to the playlist."

You know, VLC has a superpower, which is having a billion features and making sure no one finds them. Right now you can add different files to your media library, and they all show up next to each other regardless of the folder they're in. In the new [upstream VLC 4] design you have different categories, but to add anything to them you gotta go to this Browse section. Why does it have a Wi-Fi icon? Then you use this internal file explorer to find the folder you want and add the videos to your video category. None of these solve the main issue, and none of them even expose the library feature to an average user. How are you supposed to get to your library in the new VLC design? The back button, of course.

What if we use the current library design but clean it up? We have **Videos, Music, Network streams** (yes, VLC can stream, we'll get to that in a bit) **and Playlists**. On this side we have **back and forward** buttons and an **address line** you can click to go up and down in folders. We also have this view-options icon that cycles through grid, list or detail views. But what is this icon? What am I looking at? Why doesn't it change? And is that it, a search bar? Where are the sorting options? Oh, okay, they're only in the right-click menu and you're just supposed to know that. Let's make standard **sorting, view mode and search** items here. I also want to add **Unwatched first** and **Watched first** in the sorting menu, because they make your life easier. Finally, we'll have a ["…" ?] menu with different options you might need, like **adding a file or folder** here. Let's try that. All right, my folder was added, and I can finally watch the next episode.

But wait, how do we open the library? I'm thinking of something up here, but what could it be? Not a back icon, obviously. How about a home button? No, we're not going back home. A library icon? Okay, that icon's too vague. [?: The superpower line is repeated here.] How do we help everyone find the library more easily? What's the most familiar thing to someone watching something? I got it: it's the show! **The name of the folder.** You'd immediately recognize that, and we could put it right here on the top. "But Jux, how am I supposed to know I should click on that to open the library?" Exactly! Now that we have your attention, we can add another icon, like a **sidebar icon**, and have the library open here in **compact mode**. This way you never have to leave the video; you just **drag whatever you want from the library to the queue**. Of course, you can still browse the library in **full screen** if you want, with a **mini player and a queue**, and everything you could drag around. But my idea with this design is that you never have to leave the video in the first place.

## 7. Music ([12:00](https://youtu.be/ERFeOgqk324?t=720))
But this is just the videos. We also have music. I already added some of my songs here. Yes, I make my own music for my videos; if you like them, check them out. They're all in this folder called Songs, but the actual Music section gets divided into **Songs, Albums, Artists and Genres**, so you could listen to all of my songs back to back, like this one. See, it looks completely different from a video, with a **massive cover art**, and you have the **waveform seek bar** if you want.

## 8. Network streams and the Open dialogs ([12:22](https://youtu.be/ERFeOgqk324?t=742))
Let's try the network streams. By default there are a bunch of **streams saved here**, but I have this button to add whatever else we want. This normally opens a dialog like this, and this right here is a lot. We have to talk about it right now. This is an all-in-one media factory: you have file, disc, network and capture device, and not only can you play them, you can also enqueue them, stream them from your device to another device, or convert them. This is too complex. Who's coming here to select a file and enqueue it, when there's a queue right here? Plus these functions are extremely important; they should be separate, not hidden. Remember this menu up here? It already has options like **Open file, Open directory, Network stream, Capture device, Clipboard, Recent media, Convert, and Stream to another device**. Let's clean them up. Now **each of them can be its own dialog**, like this one.

And we get back to the part where we wanted to stream off the internet. There's a massive list of public TV channels from around the world on GitHub. Let's copy the link and paste it here. Now it's an **automatic playlist** with all the channels listed.

## 9. Playlists, pins, Recent, Home and resume ([13:10](https://youtu.be/ERFeOgqk324?t=790))
Speaking of playlists, that's our next stop. It's really simple: click this button, **write a name for your playlist and select your files**. That's it. Or, if you're somewhere else, you could **select a file and add it to a playlist**.

Right now this sidebar is really long and empty, but I have three more things to add. One: **pin** whatever you want here, like your favorite playlists or most-used folders. Two: a **Recent files** tab. And three: a **Home page**, duh. It would have all the **latest files, playlists and streams**. Instead of this blank cone, you'd now come back to VLC and see a full media library, ready to continue wherever you left off. Let's actually continue this. "Yes, I'd like to continue." Why is it so far away? I barely noticed it. Couldn't it be **near the other playback controls in the center**, so I'd see it, considering I have like five seconds to respond? Okay, continue.

## 10. Sponsor ([14:03](https://youtu.be/ERFeOgqk324?t=843))
[Sponsor read for Mobbin, a library of UI design examples. No design content.]

## 11. Bookmarks, chapters and on-screen messages ([14:50](https://youtu.be/ERFeOgqk324?t=890))
Wait, this is actually so cool, let me save it. How do I do that? Bookmarks. This should be it. Are you actually kidding me right now? I just want to add a bookmark and move on with my life. This is [unclear]. A shortcut like **Ctrl+B should create a bookmark quickly**, but Ctrl+B just opens this. If we brought the **bookmark timeline into the sidebar**, it would be easier to create bookmarks and see the full list. I feel like **movie chapters** would also fit perfectly here.

Anyway, let's... wait, what? What just happened? What did I press? Maybe this? Oh god, no. What am I supposed to do now? I wish this message also **showed the keyboard shortcut that was just pressed**, not just the action.

## 12. Settings ([15:27](https://youtu.be/ERFeOgqk324?t=927))
Let's see if that setting exists already. Oh, here we go. The settings screen in VLC is genuinely an airplane cockpit; this is actually rocket science. There are two setting modes, Simple and All. The simple ones aren't so simple, and the advanced ones are not all advanced. There's Interface, Audio, Video, Subtitles, Input & Codecs, and Hotkeys here.

I realize most of us use keyboard shortcuts, but many of us never dig that deep into settings. So I want to bring the **hotkeys out into their own dialog**, add a fresh coat of paint, and create a **direct button for it in the menu**.

Now the rest of this. I know I said many of us don't use the settings, but it's not because they're useless; it's because the design is so [expletive]. Right now you go to Settings, find the Interface section and look for what you need. Did you find it? Yes? Good. No? You gotta go to Advanced Settings, find Interface again, and find what you're looking for among a million different settings. What you really want is to go to Settings, find Interface, look through **all the basic settings, scroll down, and have the advanced settings right there**.

I know what you're thinking: this is too theoretical, and in practice advanced settings go on forever. That's why I went through every single setting in here and listed them one by one. It was brutal. There are settings that **repeat five times**. The same word is written differently in different places. The same setting is **worded completely differently** in simple and advanced settings. Some subcategories literally have **one single setting** inside them. The parametric equalizer is pathetic. The settings have explanations, but they're **hidden and only show if you leave your mouse on them** long enough. And the dumbest one yet is how auto-detecting subtitles in a folder uses **different degrees of precision as numbers**. Seriously, VLC, what does that even mean? If you hover over it, it says: match movie filename to no sub file, any sub file, sub files containing the movie name, movie name and additional characters, or exactly the movie name. Okay, cool. So why are we using numbers? We are not computers. Just put them in **human words in a dropdown**. Use your words, VLC.

After going through every setting, I divided them into ten or more categories:
- **General** for general app settings, including **theme selection for light and dark mode**. I also want an **accent color** setting, so you can change the orange to whatever color you like.
- **Interface** for how VLC behaves.
- **Privacy** for what VLC needs to remember about history or network.
- **Controls** for all the keyboard and mouse settings.
- **Playback** for all the settings related to when a file is playing.
- **Video** for video and picture settings, like all the filters.
- **Audio** for audio filters like the equalizer, and so on.
- **Subtitles** for all the subtitle and **on-screen display** messages, like showing the keyboard shortcuts as we press them.
- **Library** for playlists, folders and so on.
- **Network** for all the connection options.
- **Performance** for all the decoding and CPU usage settings.
- **Recording** for streaming or casting to another device.
- **Extensions** for a list of all of them. Extensions in VLC right now are a mashup of add-ons, extensions and plugins. They sound like synonyms, but add-ons are like extensions, skins, and everything installable, while **plugins are VLC's internal functions**; you're not really supposed to edit them here, so they **go in the advanced settings** part.

And that's settings for you. Everything is clean, and **every setting has an info icon** that shows more information about it.

## 13. Customization and profiles ([18:55](https://youtu.be/ERFeOgqk324?t=1135))
But there's one big part left. I wouldn't make customization part of this redesign, because that would just be your redesign, right? But since VLC has a screen for it and it's not very good, we have to do this. The customization dialog right now is very hard to use, and it doesn't have to be like this. We can simply have **one big frame in the center of VLC, filled with buttons and icons, with outlines showing you that you can move things**. That's it. You just drag whatever you want around, bring things in, take them out, and make something that's completely yours. For example, this is an **alternate layout** I thought of. I also think you should be able to **save different layouts under different VLC profiles**, so all your settings change with every profile.

## 14. Onboarding and outro ([19:38](https://youtu.be/ERFeOgqk324?t=1178))
But here's the thing: I asked you how far you'd go to customize your media player, and even though most of you want to customize, about half of you chose to keep customization to a minimum. A simple solution is an **onboarding screen**, with **theme options** and a **shortcut screen** introducing the basic shortcuts. That would be really helpful.

If you like the redesign and want to contribute to VLC in any way, **this redesign will be open source and free to use**. And if you like the VLC project and can, consider donating to VLC. The links are all in the description.

Putting this all together: the all-time favorite media player is back with a brand-new UI. A refreshed library for a refreshed experience. Videos, music, streaming and playlists are right next to you. Drag everything you want to the queue and play. Seek through the video with ease. More is less: do more with less effort. Settings reimagined, from syncing your subtitles with an easy subtitle timeline, to creating audio and video filters, and choosing your own color. Everything is customizable. Yep, even that. Just drag and drop. Your player, your VLC.
