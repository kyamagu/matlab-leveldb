function make(varargin)
%MAKE Build MEX files.
%
% Build MEX files in the project. Uses GNU Make.
%
% Example
%
% leveldb.make
% leveldb.make('test')
% leveldb.make('clean')
% leveldb.make('clean_all')
%
% leveldb.make('LEVELDB_VERSION=1.17')
%
  root = fileparts(fileparts(mfilename('fullpath')));
  command = sprintf('make -C %s MATLABDIR=%s%s', ...
                    root, ...
                    matlabroot, ...
                    sprintf(' %s', varargin{:}));
  disp(command);
  system(command);
end
