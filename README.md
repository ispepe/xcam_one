# xcam_one
全景相机

### 默认样式融合

```dart
Widget text = DefaultTextStyle.merge(
  style: customStyle.copyWith(
    fontSize: selectedFontSize,
    color: colorTween.evaluate(animation),
  ),
  // The font size should grow here when active, but because of the way
  // font rendering works, it doesn't grow smoothly if we just animate
  // the font size, so we use a transform instead.
  child: Transform(
    transform: Matrix4.diagonal3(
      Vector3.all(
        Tween<double>(
          begin: unselectedFontSize! / selectedFontSize!,
          end: 1.0,
        ).evaluate(animation),
      ),
    ),
    alignment: Alignment.bottomCenter,
    child: item.title ?? Text(item.label!),
  ),
);
```