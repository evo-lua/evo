local path = require("./Core/Environment/path")

_G.currentNamespace = "win32"

assertStrictEqual(path.win32.normalize('./fixtures///b/../b/c.js'),
                   'fixtures\\b\\c.js');
assertStrictEqual(path.win32.normalize('/foo/../../../bar'), '\\bar');
assertStrictEqual(path.win32.normalize('a//b//../b'), 'a\\b');
assertStrictEqual(path.win32.normalize('a//b//./c'), 'a\\b\\c');
assertStrictEqual(path.win32.normalize('a//b//.'), 'a\\b');
assertStrictEqual(path.win32.normalize('//server/share/dir/file.ext'),
                   '\\\\server\\share\\dir\\file.ext');
assertStrictEqual(path.win32.normalize('/a/b/c/../../../x/y/z'), '\\x\\y\\z');
assertStrictEqual(path.win32.normalize('C:'), 'C:.');
assertStrictEqual(path.win32.normalize('C:..\\abc'), 'C:..\\abc');
assertStrictEqual(path.win32.normalize('C:..\\..\\abc\\..\\def'),
                   'C:..\\..\\def');
assertStrictEqual(path.win32.normalize('C:\\.'), 'C:\\');
assertStrictEqual(path.win32.normalize('file:stream'), 'file:stream');
assertStrictEqual(path.win32.normalize('bar\\foo..\\..\\'), 'bar\\');
assertStrictEqual(path.win32.normalize('bar\\foo..\\..'), 'bar');
assertStrictEqual(path.win32.normalize('bar\\foo..\\..\\baz'), 'bar\\baz');
assertStrictEqual(path.win32.normalize('bar\\foo..\\'), 'bar\\foo..\\');
assertStrictEqual(path.win32.normalize('bar\\foo..'), 'bar\\foo..');
assertStrictEqual(path.win32.normalize('..\\foo..\\..\\..\\bar'),
                   '..\\..\\bar');
assertStrictEqual(path.win32.normalize('..\\...\\..\\.\\...\\..\\..\\bar'),
                   '..\\..\\bar');
assertStrictEqual(path.win32.normalize('../../../foo/../../../bar'),
                   '..\\..\\..\\..\\..\\bar');
assertStrictEqual(path.win32.normalize('../../../foo/../../../bar/../../'),
                   '..\\..\\..\\..\\..\\..\\');
assertStrictEqual(
  path.win32.normalize('../foobar/barfoo/foo/../../../bar/../../'),
  '..\\..\\'
);
assertStrictEqual(
  path.win32.normalize('../.../../foobar/../../../bar/../../baz'),
  '..\\..\\..\\..\\baz'
);
assertStrictEqual(path.win32.normalize('foo/bar\\baz'), 'foo\\bar\\baz');

_G.currentNamespace = "posix"
assertStrictEqual(path.posix.normalize('./fixtures///b/../b/c.js'),
                   'fixtures/b/c.js');
assertStrictEqual(path.posix.normalize('/foo/../../../bar'), '/bar');
assertStrictEqual(path.posix.normalize('a//b//../b'), 'a/b');
assertStrictEqual(path.posix.normalize('a//b//./c'), 'a/b/c');
assertStrictEqual(path.posix.normalize('a//b//.'), 'a/b');
assertStrictEqual(path.posix.normalize('/a/b/c/../../../x/y/z'), '/x/y/z');
assertStrictEqual(path.posix.normalize('///..//./foo/.//bar'), '/foo/bar');
assertStrictEqual(path.posix.normalize('bar/foo../../'), 'bar/');
assertStrictEqual(path.posix.normalize('bar/foo../..'), 'bar');
assertStrictEqual(path.posix.normalize('bar/foo../../baz'), 'bar/baz');
assertStrictEqual(path.posix.normalize('bar/foo../'), 'bar/foo../');
assertStrictEqual(path.posix.normalize('bar/foo..'), 'bar/foo..');
assertStrictEqual(path.posix.normalize('../foo../../../bar'), '../../bar');
assertStrictEqual(path.posix.normalize('../.../.././.../../../bar'),
                   '../../bar');
assertStrictEqual(path.posix.normalize('../../../foo/../../../bar'),
                   '../../../../../bar');
assertStrictEqual(path.posix.normalize('../../../foo/../../../bar/../../'),
                   '../../../../../../');
assertStrictEqual(
  path.posix.normalize('../foobar/barfoo/foo/../../../bar/../../'),
  '../../'
);
assertStrictEqual(
  path.posix.normalize('../.../../foobar/../../../bar/../../baz'),
  '../../../../baz'
);
assertStrictEqual(path.posix.normalize('foo/bar\\baz'), 'foo/bar\\baz');
