# Readme

Sequoia is a modern eye-candy theme for SDDM, making use of Nerd Fonts for its icons.

Written from scratch, it is primarily made for standalone SDDM, aiming to be customisable with accessibility options.

![theme screenshot](preview.png "Preview")
![login screenshot](https://github.com/user-attachments/assets/7bc865a4-4d5c-4411-9148-57cf7fa3d80c "Session selection")


## Dependencies

* SDDM
* [a Nerd Font](https://www.nerdfonts.com/) >= v3.0
* Qt5
  * Qt Quick Controls 2
  * Qt Graphical Effects

## Installation

**This guide only covers manual installation on desktop environments other than KDE Plasma for now**

1- Once you have downloaded the tarball through the releases tab, extract it to the SDDM theme directory *(change the archive path if needed)*:

```
$ sudo tar -xzvf ~/sequoia.tar.gz -C /usr/share/sddm/themes
```

2- Edit your [SDDM config file](https://man.archlinux.org/man/sddm.conf.5) under `[Theme]` change `Current` to `Current=sequoia` *(make sure to match the theme name with the theme's directory)*

It should look like this:

```conf
[Theme]
Current=sequoia
```

### Testing

You can easily try out themes without changing your SDDM config or repeatedly logging out using this command:

```
$ sddm-greeter --test-mode --theme /path/to/your/theme
```

It's quite the time-saver when configuring your `theme.conf` file.

## Support

If you want to show support by buying me a coffee or send a tip feel free to visit my ko-fi page :3
[![ko-fi](https://ko-fi.com/img/githubbutton_sm.svg)](https://ko-fi.com/Y8Y0473AA)
