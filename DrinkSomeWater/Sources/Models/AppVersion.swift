import Foundation

struct AppVersion: Comparable, CustomStringConvertible {
  let major: Int
  let minor: Int
  let patch: Int

  var description: String {
    "\(major).\(minor).\(patch)"
  }

  init(major: Int, minor: Int, patch: Int) {
    self.major = major
    self.minor = minor
    self.patch = patch
  }

  init?(string: String) {
    let components = string.split(separator: ".").compactMap { Int($0) }
    guard components.count >= 2 else { return nil }

    self.major = components[0]
    self.minor = components[1]
    self.patch = components.count >= 3 ? components[2] : 0
  }

  static var current: AppVersion? {
    guard let versionString = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
      return nil
    }
    return AppVersion(string: versionString)
  }

  static func < (lhs: AppVersion, rhs: AppVersion) -> Bool {
    if lhs.major != rhs.major {
      return lhs.major < rhs.major
    }
    if lhs.minor != rhs.minor {
      return lhs.minor < rhs.minor
    }
    return lhs.patch < rhs.patch
  }
}
