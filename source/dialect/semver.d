/++
 +  SemVer information about the current release.
 +
 +  Contains only definitions, no code. Helps importing projects tell what
 +  features are available.
 +/
module dialect.semver;


/// SemVer versioning of this build.
enum DialectSemVer
{
    majorVersion = 0,  /// SemVer major version of the library.
    minorVersion = 5,  /// SemVer minor version of the library.
    patchVersion = 0,  /// SemVer patch version of the library.
}


/// Pre-release SemVer subversion of this build.
enum dialectSemVerPrerelease = string.init;