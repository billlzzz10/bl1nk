// Placeholder types to decouple from AppFlowy deps

enum CoverType { color, asset, file }

enum CoverTypePB { ColorCover, AssetCover, FileCover }

extension IntoCoverTypePB on CoverType {
  CoverTypePB into() => switch (this) {
        CoverType.color => CoverTypePB.ColorCover,
        CoverType.asset => CoverTypePB.AssetCover,
        CoverType.file => CoverTypePB.FileCover,
      };
}
