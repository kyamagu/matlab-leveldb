classdef WriteBatch < handle
%WRITEBATCH LevelDB WriteBatch wrapper.
%
% See also leveldb

properties (SetAccess = private, Hidden)
  id_ % ID of the session.
end

methods
  function this = WriteBatch()
  %WRITEBATCH Create a new batch.
    assert(isscalar(this));
    this.id_ = LevelDB_('batch_new');
  end

  function delete(this)
  %DELETE Destructor.
    assert(isscalar(this));
    LevelDB_('batch_delete', this.id_);
  end

  function put(this, key, value, varargin)
  %PUT Save something to the database.
    assert(isscalar(this));
    LevelDB_('batch_put', this.id_, key, value);
  end

  function remove(this, key, varargin)
  %REMOVE Remove data.
    assert(isscalar(this));
    LevelDB_('batch_remove', this.id_, key);
  end
end

end
