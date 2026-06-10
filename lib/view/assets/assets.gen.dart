// dart format width=80

/// GENERATED CODE - DO NOT MODIFY BY HAND
/// *****************************************************
///  FlutterGen
/// *****************************************************

// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: deprecated_member_use,directives_ordering,implicit_dynamic_list_literal,unnecessary_import

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart' as _svg;
import 'package:lottie/lottie.dart' as _lottie;
import 'package:vector_graphics/vector_graphics.dart' as _vg;

class $AssetsFontsGen {
  const $AssetsFontsGen();

  /// Directory path: assets/fonts/roboto
  $AssetsFontsRobotoGen get roboto => const $AssetsFontsRobotoGen();
}

class $AssetsJsonGen {
  const $AssetsJsonGen();

  /// File path: assets/json/splash.json
  LottieGenImage get splash => const LottieGenImage('assets/json/splash.json');

  /// List of all assets
  List<LottieGenImage> get values => [splash];
}

class $AssetsMediaGen {
  const $AssetsMediaGen();

  /// Directory path: assets/media/images
  $AssetsMediaImagesGen get images => const $AssetsMediaImagesGen();

  /// Directory path: assets/media/sounds
  $AssetsMediaSoundsGen get sounds => const $AssetsMediaSoundsGen();

  /// Directory path: assets/media/videos
  $AssetsMediaVideosGen get videos => const $AssetsMediaVideosGen();
}

class $AssetsFontsRobotoGen {
  const $AssetsFontsRobotoGen();

  /// File path: assets/fonts/roboto/Roboto-Light.ttf
  String get robotoLight => 'assets/fonts/roboto/Roboto-Light.ttf';

  /// List of all assets
  List<String> get values => [robotoLight];
}

class $AssetsMediaImagesGen {
  const $AssetsMediaImagesGen();

  /// Directory path: assets/media/images/png
  $AssetsMediaImagesPngGen get png => const $AssetsMediaImagesPngGen();

  /// Directory path: assets/media/images/svg
  $AssetsMediaImagesSvgGen get svg => const $AssetsMediaImagesSvgGen();
}

class $AssetsMediaSoundsGen {
  const $AssetsMediaSoundsGen();

  /// File path: assets/media/sounds/test_sound.mp3
  String get testSound => 'assets/media/sounds/test_sound.mp3';

  /// List of all assets
  List<String> get values => [testSound];
}

class $AssetsMediaVideosGen {
  const $AssetsMediaVideosGen();

  /// File path: assets/media/videos/test_video.mp4
  String get testVideo => 'assets/media/videos/test_video.mp4';

  /// List of all assets
  List<String> get values => [testVideo];
}

class $AssetsMediaImagesPngGen {
  const $AssetsMediaImagesPngGen();

  /// File path: assets/media/images/png/app_logo.png
  AssetGenImage get appLogo =>
      const AssetGenImage('assets/media/images/png/app_logo.png');

  /// File path: assets/media/images/png/onboarding_img.png
  AssetGenImage get onboardingImg =>
      const AssetGenImage('assets/media/images/png/onboarding_img.png');

  /// List of all assets
  List<AssetGenImage> get values => [appLogo, onboardingImg];
}

class $AssetsMediaImagesSvgGen {
  const $AssetsMediaImagesSvgGen();

  /// File path: assets/media/images/svg/app_logo.svg
  SvgGenImage get appLogo =>
      const SvgGenImage('assets/media/images/svg/app_logo.svg');

  /// File path: assets/media/images/svg/onboarding_background.svg
  SvgGenImage get onboardingBackground =>
      const SvgGenImage('assets/media/images/svg/onboarding_background.svg');

  /// List of all assets
  List<SvgGenImage> get values => [appLogo, onboardingBackground];
}

class Assets {
  const Assets._();

  static const $AssetsFontsGen fonts = $AssetsFontsGen();
  static const $AssetsJsonGen json = $AssetsJsonGen();
  static const $AssetsMediaGen media = $AssetsMediaGen();
}

class AssetGenImage {
  const AssetGenImage(
    this._assetName, {
    this.size,
    this.flavors = const {},
    this.animation,
  });

  final String _assetName;

  final Size? size;
  final Set<String> flavors;
  final AssetGenImageAnimation? animation;

  Image image({
    Key? key,
    AssetBundle? bundle,
    ImageFrameBuilder? frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    String? semanticLabel,
    bool excludeFromSemantics = false,
    double? scale,
    double? width,
    double? height,
    Color? color,
    Animation<double>? opacity,
    BlendMode? colorBlendMode,
    BoxFit? fit,
    AlignmentGeometry alignment = Alignment.center,
    ImageRepeat repeat = ImageRepeat.noRepeat,
    Rect? centerSlice,
    bool matchTextDirection = false,
    bool gaplessPlayback = true,
    bool isAntiAlias = false,
    String? package,
    FilterQuality filterQuality = FilterQuality.medium,
    int? cacheWidth,
    int? cacheHeight,
  }) {
    return Image.asset(
      _assetName,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      semanticLabel: semanticLabel,
      excludeFromSemantics: excludeFromSemantics,
      scale: scale,
      width: width,
      height: height,
      color: color,
      opacity: opacity,
      colorBlendMode: colorBlendMode,
      fit: fit,
      alignment: alignment,
      repeat: repeat,
      centerSlice: centerSlice,
      matchTextDirection: matchTextDirection,
      gaplessPlayback: gaplessPlayback,
      isAntiAlias: isAntiAlias,
      package: package,
      filterQuality: filterQuality,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
    );
  }

  ImageProvider provider({AssetBundle? bundle, String? package}) {
    return AssetImage(_assetName, bundle: bundle, package: package);
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class AssetGenImageAnimation {
  const AssetGenImageAnimation({
    required this.isAnimation,
    required this.duration,
    required this.frames,
  });

  final bool isAnimation;
  final Duration duration;
  final int frames;
}

class SvgGenImage {
  const SvgGenImage(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = false;

  const SvgGenImage.vec(this._assetName, {this.size, this.flavors = const {}})
    : _isVecFormat = true;

  final String _assetName;
  final Size? size;
  final Set<String> flavors;
  final bool _isVecFormat;

  _svg.SvgPicture svg({
    Key? key,
    bool matchTextDirection = false,
    AssetBundle? bundle,
    String? package,
    double? width,
    double? height,
    BoxFit fit = BoxFit.contain,
    AlignmentGeometry alignment = Alignment.center,
    bool allowDrawingOutsideViewBox = false,
    WidgetBuilder? placeholderBuilder,
    String? semanticsLabel,
    bool excludeFromSemantics = false,
    _svg.SvgTheme? theme,
    _svg.ColorMapper? colorMapper,
    ColorFilter? colorFilter,
    Clip clipBehavior = Clip.hardEdge,
    @deprecated Color? color,
    @deprecated BlendMode colorBlendMode = BlendMode.srcIn,
    @deprecated bool cacheColorFilter = false,
  }) {
    final _svg.BytesLoader loader;
    if (_isVecFormat) {
      loader = _vg.AssetBytesLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
      );
    } else {
      loader = _svg.SvgAssetLoader(
        _assetName,
        assetBundle: bundle,
        packageName: package,
        theme: theme,
        colorMapper: colorMapper,
      );
    }
    return _svg.SvgPicture(
      loader,
      key: key,
      matchTextDirection: matchTextDirection,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      allowDrawingOutsideViewBox: allowDrawingOutsideViewBox,
      placeholderBuilder: placeholderBuilder,
      semanticsLabel: semanticsLabel,
      excludeFromSemantics: excludeFromSemantics,
      colorFilter:
          colorFilter ??
          (color == null ? null : ColorFilter.mode(color, colorBlendMode)),
      clipBehavior: clipBehavior,
      cacheColorFilter: cacheColorFilter,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}

class LottieGenImage {
  const LottieGenImage(this._assetName, {this.flavors = const {}});

  final String _assetName;
  final Set<String> flavors;

  _lottie.LottieBuilder lottie({
    Animation<double>? controller,
    bool? animate,
    _lottie.FrameRate? frameRate,
    bool? repeat,
    bool? reverse,
    _lottie.LottieDelegates? delegates,
    _lottie.LottieOptions? options,
    void Function(_lottie.LottieComposition)? onLoaded,
    _lottie.LottieImageProviderFactory? imageProviderFactory,
    Key? key,
    AssetBundle? bundle,
    Widget Function(BuildContext, Widget, _lottie.LottieComposition?)?
    frameBuilder,
    ImageErrorWidgetBuilder? errorBuilder,
    double? width,
    double? height,
    BoxFit? fit,
    AlignmentGeometry? alignment,
    String? package,
    bool? addRepaintBoundary,
    FilterQuality? filterQuality,
    void Function(String)? onWarning,
    _lottie.LottieDecoder? decoder,
    _lottie.RenderCache? renderCache,
    bool? backgroundLoading,
  }) {
    return _lottie.Lottie.asset(
      _assetName,
      controller: controller,
      animate: animate,
      frameRate: frameRate,
      repeat: repeat,
      reverse: reverse,
      delegates: delegates,
      options: options,
      onLoaded: onLoaded,
      imageProviderFactory: imageProviderFactory,
      key: key,
      bundle: bundle,
      frameBuilder: frameBuilder,
      errorBuilder: errorBuilder,
      width: width,
      height: height,
      fit: fit,
      alignment: alignment,
      package: package,
      addRepaintBoundary: addRepaintBoundary,
      filterQuality: filterQuality,
      onWarning: onWarning,
      decoder: decoder,
      renderCache: renderCache,
      backgroundLoading: backgroundLoading,
    );
  }

  String get path => _assetName;

  String get keyName => _assetName;
}
