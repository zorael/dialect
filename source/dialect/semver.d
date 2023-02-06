/++
    SemVer information about the current release.

    Contains only definitions, no code. Helps importing projects tell what
    features are available.
 +/
module dialect.semver;


/// SemVer versioning of this build.
enum DialectSemVer
{
    major = 1,  /// SemVer major version of the library.
    minor = 5,  /// SemVer minor version of the library.
    patch = 0,  /// SemVer patch version of the library.
}


/// Pre-release SemVer subversion of this build.
enum DialectSemVerPrerelease = string.init;
