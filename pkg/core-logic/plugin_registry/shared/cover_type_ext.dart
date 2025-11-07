// Placeholder types while AppFlowy dependencies are decoupled

enum CoverType {
  none,
  color,
  asset,
  file,
}

enum CoverTypePB {
  None,
  ColorCover,
  AssetCover,
  FileCover,
}

extension IntoCoverTypePB on CoverType {
  CoverTypePB into() => switch (this) {
        CoverType.color => CoverTypePB.ColorCover,
        CoverType.asset => CoverTypePB.AssetCover,
        CoverType.file => CoverTypePB.FileCover,
        _ => CoverTypePB.FileCover,
      };
}