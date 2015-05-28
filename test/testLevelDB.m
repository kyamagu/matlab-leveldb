function testLevelDB
%TESTLEVELDB Test the functionality of LevelDB wrapper.
  addpath(fileparts(fileparts(mfilename('fullpath'))));
  tests = {...
    'testOperations', ...
    'testBatchAPI', ...
    'testIteratorAPI', ...
    'testDumpAPI' ...
  };
  database = leveldb.DB('_testdb');
  for i = 1:numel(tests)
    runTest(tests{i}, database);
  end
  clear database;
  if exist('_testdb', 'dir')
    rmdir('_testdb', 's');
  end
end

function runTest(test, database)
  fprintf('=== %s ===\n', test);
  try
    feval(str2func(test), database);
    fprintf('SUCCESS\n');
  catch exception
    fprintf('FAIL: %s\n', exception.identifier);
    disp(exception.getReport());
  end
end

function testOperations(database)
  value = database.get('some-key');
  assert(isempty(value));
  database.put('another-key', 'foo');
  value = database.get('another-key');
  assert(strcmp(value, 'foo'));
end

function testBatchAPI(database)
  batch = leveldb.WriteBatch();
  batch.put('a', 'b');
  batch.put('yet-another-key', 'bar');
  batch.remove('a');
  database.write(batch);
end

function testIteratorAPI(database)
  database.each(@(key, value) disp([key, ':', value]));
  foo_counter = @(key, value, accum) accum + strcmp(value, 'foo');
  foo_count = database.reduce(foo_counter, 0);
  it = database.iterator();
  it.first();
  while it.next()
    fprintf('%s: %s\n', it.key, it.value);
  end
  it.last();
  while it.previous()
    fprintf('%s: %s\n', it.key, it.value);
  end
  clear it;
  fprintf('Number of ''foo'': %d\n', foo_count);
end

function testDumpAPI(database)
  disp(database.keys());
  disp(database.values());
end
