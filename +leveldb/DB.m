classdef DB < handle
%DB LevelDB DB wrapper.
%
% % Open and close.
% database = leveldb.DB('./db');
% clear database;
%
% % Read and write.
% database.put('key1', 'value1');
% database.put('key2', 'value2');
% value1 = database.get('key1');
% database.remove('key1');
%
% % Transaction.
% batch = leveldb.WriteBatch();
% batch.put('key3', 'value3');
% batch.put('key4', 'value4');
% database.write(batch);
%
% % Iterator.
% database.each(@(key, value) disp([key, ':', 'value']));
% count = database.reduce(@(key, value, count) count + 1, 0);
%
% See also leveldb

properties (Access = private)
  id_ % ID of the session.
end

methods
  function this = DB(filename, varargin)
  %DB Create a new database.
  %
  % database = leveldb.DB('./db')
  % database = leveldb.DB('./db', 'ErrorIfExists', true, ...)
  %
  % Options
  %   'CreateIfMissing' default true
  %   'ErrorIfExists'   default false
  %   'ParanoidChecks'  default false
    assert(isscalar(this));
    assert(ischar(filename));
    this.id_ = LevelDB_('new', filename, varargin{:});
  end

  function delete(this)
  %DELETE Destructor.
    assert(isscalar(this));
    LevelDB_('delete', this.id_);
  end

  function result = get(this, key)
  %GET Query a record.
    assert(isscalar(this));
    result = LevelDB_('get', this.id_, key);
  end

  function put(this, key, value, varargin)
  %PUT Save a record in the database.
  %
  % Options
  %   'Sync' default false
    assert(isscalar(this));
    LevelDB_('put', this.id_, key, value, varargin{:});
  end

  function remove(this, key, varargin)
  %REMOVE Remove a record.
  %
  % Options
  %   'Sync' default false
    assert(isscalar(this));
    LevelDB_('remove', this.id_, key, varargin{:});
  end

  function write(this, batch, varargin)
  %WRITE Write a batch.
  %
  % batch = leveldb.WriteBatch();
  % batch.put('foo', 'bar');
  % batch.remove('baz');
  % database.Write(batch, 'Sync', true);
  %
  % Options
  %   'Sync' default false
    assert(isscalar(this));
    assert(isscalar(batch) && isa(batch, 'leveldb.WriteBatch'));
    LevelDB_('write', this.id_, batch.id_, varargin{:});
  end

  function each(this, func)
  %EACH Apply a function to each record.
  %
  % Example: show each record.
  %
  % database.each(@(key, value) disp([key, ': ', value]))
    assert(isscalar(this));
    assert(ischar(func) || isa(func, 'function_handle'));
    assert(abs(nargin(func)) > 1);
    LevelDB_('each', this.id_, func);
  end

  function result = reduce(this, func, initial_value)
  %REDUCE Apply an accumulation function to each record.
  %
  % Example: counting the number of 'foo' in the records.
  %
  % database.reduce(@(key, val, accum) accum + strcmp(val, 'foo'), 0)
    assert(isscalar(this));
    assert(ischar(func) || isa(func, 'function_handle'));
    assert(abs(nargin(func)) > 2 && abs(nargout(func)) > 0);
    result = LevelDB_('reduce', this.id_, func, initial_value);
  end
end

end
