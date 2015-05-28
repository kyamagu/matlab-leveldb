classdef Iterator < handle
%ITERATOR LevelDB Iterator wrapper.
%
% it = database.iterator();
% while it.next()
%   key = it.key;
%   value = it.value;
% end
% clear it;
%
% See also leveldb.DB

properties (Access = private)
  id_ % ID of the session.
end

properties (Dependent, SetAccess = private)
  key
  value
end

methods (Hidden)
  function this = Iterator(database_id)
  %ITERATOR Create a new iterator.
  %
  % it = database.iterator();
    assert(isscalar(this));
    this.id_ = LevelDB_('iterator_new', database_id);
  end
end

methods
  function delete(this)
  %DELETE Destructor.
    assert(isscalar(this));
    LevelDB_('iterator_delete', this.id_);
  end

  function flag = next(this)
  %NEXT Moves to the next entry in the source.
    assert(isscalar(this));
    flag = LevelDB_('iterator_next', this.id_);
  end

  function flag = previous(this)
  %PREVIOUS Moves to the previous entry in the source.
    assert(isscalar(this));
    flag = LevelDB_('iterator_previous', this.id_);
  end

  function flag = first(this)
  %FIRST Position at the first key in the source.
    assert(isscalar(this));
    flag = LevelDB_('iterator_first', this.id_);
  end

  function flag = last(this)
  %LAST Position at the last key in the source.
    assert(isscalar(this));
    flag = LevelDB_('iterator_last', this.id_);
  end

  function key_value = get.key(this)
  %KEY Return the key for the current entry.
    key_value = LevelDB_('iterator_key', this.id_);
  end

  function value_value = get.value(this)
  %VALUE Return the value for the current entry.
    value_value = LevelDB_('iterator_value', this.id_);
  end
end

end
