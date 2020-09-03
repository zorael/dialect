/++
    SemVer information about the current release.

    Contains only definitions, no code. Helps importing projects tell what
    features are available.
 +/
module dialect.semver;


/// SemVer versioning of this build.
enum DialectSemVer
{
    majorVersion = 0,  /// SemVer major version of the library.
    minorVersion = 6,  /// SemVer minor version of the library.
    patchVersion = 1,  /// SemVer patch version of the library.
}


/// Pre-release SemVer subversion of this build.
enum DialectSemVerPrerelease = string.init;
