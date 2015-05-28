Matlab LevelDB
==============

Matlab LevelDB wrapper designed for UNIX environment.

The implementation is based on [mexplus](http://github.com/kyamagu/mexplus).

 * [LevelDB](https://code.google.com/p/leveldb/)

See also [matlab-lmdb](http://github.com/kyamagu/matlab-lmdb).

Build
-----

As a prerequisite, LevelDB must be installed. In Linux, install via a package
manager, e.g.,

    apt-get install libleveldb-dev

Launch Matlab and do the following.

    addpath /path/to/matlab-leveldb;
    leveldb.make();
    leveldb.make('test');

The `leveldb.make()` function internally calls GNU Make. By default, the build
process automatically downloads a leveldb source package from GitHub. Edit
`Makefile` to customize the build process.

Example
-------

    % Open and close.
    database = leveldb.DB('./db');
    clear database;

    % Read and write.
    database.put('key1', 'value1');
    database.put('key2', 'value2');
    value1 = database.get('key1');
    database.remove('key1');

    % Transaction.
    batch = leveldb.WriteBatch();
    batch.put('key3', 'value3');
    batch.put('key4', 'value4');
    database.write(batch);

    % Iterator.
    database.each(@(key, value) disp([key, ': ', value]));
    count = database.reduce(@(key, value, count) count + 1, 0);

    % Dump.
    keys = database.keys();
    values = database.values();
