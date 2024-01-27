/++
    SemVer information about the current release.

    Contains only definitions, no code. Helps importing projects tell what
    features are available.

    Copyright: [JR](https://github.com/zorael)
    License: [Boost Software License 1.0](https://www.boost.org/users/license.html)

    Authors:
        [JR](https://github.com/zorael)
 +/
module dialect.semver;


/// SemVer versioning of this build.
enum DialectSemVer
{
    major = 2,  /// SemVer major version of the library.
    minor = 1,  /// SemVer minor version of the library.
    patch = 0,  /// SemVer patch version of the library.
}


/// Pre-release SemVer subversion of this build.
enum DialectSemVerPrerelease = string.init;
