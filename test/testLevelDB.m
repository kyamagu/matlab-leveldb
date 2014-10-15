function testLevelDB
%TESTLEVELDB Test the functionality of LevelDB wrapper.
  addpath(fileparts(fileparts(mfilename('fullpath'))));
  % Using a database object.
  database = leveldb.DB('_testdb');
  value = database.get('some-key');
  assert(isempty(value));
  database.put('another-key', 'foo');
  value = database.get('another-key');
  assert(strcmp(value, 'foo'));
  % Batch API.
  batch = leveldb.WriteBatch();
  batch.put('a', 'b');
  batch.put('yet-another-key', 'bar');
  batch.remove('a');
  database.write(batch);
  % Iterator API.
  database.each(@(key, value) disp([key, ':', value]));
  foo_counter = @(key, value, accum) accum + strcmp(value, 'foo');
  foo_count = database.reduce(foo_counter, 0);
  fprintf('Number of ''foo'': %d\n', foo_count);
  clear database;
  if exist('_testdb', 'dir')
    rmdir('_testdb', 's');
  end
  fprintf('SUCCESS\n');

end
