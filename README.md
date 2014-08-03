Matlab LevelDB
==============

Matlab LevelDB wrapper.

The implementation is based on [mexplus](http://github.com/kyamagu/mexplus).

Prerequisite
------------

 * [LevelDB](https://code.google.com/p/leveldb/)

You may install LevelDB via a package manager, such as `apt-get`.

Build
-----

    addpath /path/to/matlab-leveldb;
    leveldb.make();

To specify optional build flags:

    leveldb.make('all', '-I/opt/local/include -L/opt/local/lib');

Run a test:

    leveldb.make('test');

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
