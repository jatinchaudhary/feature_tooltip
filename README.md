# feature_tooltip

`feature_tooltip` is a Flutter package that provides a highly configurable tooltip
widget. Unlike the built‑in `Tooltip`, this widget supports custom positioning,
fine‑tuned styling, show/hide animations, extended display durations and an
optional blurred backdrop. It's designed to be flexible enough for most UI
requirements.

## Features

- **Custom positioning** – decide whether the tooltip appears above, below, to
  the left or to the right of the anchor. You can also fine‑tune the offset.
- **Styling** – customise padding, margin, background colour, text style,
  border radius, elevation and arrow dimensions.
- **Animations** – smooth fade and slide animations with configurable duration
  and easing curves.
- **Extended timeout** – choose how long the tooltip stays on screen. It can
  remain indefinitely until dismissed, or automatically disappear after a
  specified duration.
- **Background blur** – optionally blur the content behind the tooltip to draw
  attention.
- **Triggers** – show tooltips on tap, long‑press or manually through the API.

## Getting Started

Add the dependency to your project's `pubspec.yaml`:

```yaml
dependencies:
  feature_tooltip:
    git:
      url: https://github.com/your‑username/feature_tooltip.git
      ref: main
```

Import it where you need the tooltip:

```dart
import 'package:feature_tooltip/feature_tooltip.dart';
```

Wrap the widget you want to anchor the tooltip to with `FeatureTooltip`.
Pass the message or your own custom content along with any additional
configuration:

```dart
FeatureTooltip(
  message: 'This is an advanced tooltip',
  direction: TooltipDirection.up,
  backgroundColor: Colors.blueGrey,
  textStyle: TextStyle(color: Colors.white),
  blurBackground: true,
  child: Icon(Icons.info_outline),
);
```

For a more complete example see the `/example` directory.
