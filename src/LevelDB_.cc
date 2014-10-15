/** LevelDB Matlab wrapper.
 */
#include <leveldb/db.h>
#include <leveldb/write_batch.h>
#include <memory>
#include <mexplus.h>

using namespace std;
using namespace mexplus;

#define ASSERT(cond, ...) \
    if (!(cond)) mexErrMsgIdAndTxt("leveldb:error", __VA_ARGS__)

// Instance manager for Database.
template class mexplus::Session<leveldb::DB>;
template class mexplus::Session<leveldb::WriteBatch>;

namespace {

MEX_DEFINE(new) (int nlhs, mxArray* plhs[],
                 int nrhs, const mxArray* prhs[]) {
  InputArguments input(nrhs, prhs, 1, 3, "CreateIfMissing", "ErrorIfExists",
      "ParanoidChecks");
  OutputArguments output(nlhs, plhs, 1);
  leveldb::Options options;
  options.create_if_missing = input.get<bool>("CreateIfMissing", true);
  options.error_if_exists = input.get<bool>("ErrorIfExists", false);
  options.paranoid_checks = input.get<bool>("ParanoidChecks", false);
  leveldb::DB* database = NULL;
  leveldb::Status status_ = leveldb::DB::Open(options,
                                              input.get<string>(0),
                                              &database);
  ASSERT(status_.ok(), status_.ToString().c_str());
  output.set(0, Session<leveldb::DB>::create(database));
}

MEX_DEFINE(delete) (int nlhs, mxArray* plhs[],
                    int nrhs, const mxArray* prhs[]) {
  InputArguments input(nrhs, prhs, 1);
  OutputArguments output(nlhs, plhs, 0);
  Session<leveldb::DB>::destroy(input.get(0));
}

MEX_DEFINE(get) (int nlhs, mxArray* plhs[],
                 int nrhs, const mxArray* prhs[]) {
  InputArguments input(nrhs, prhs, 2);
  OutputArguments output(nlhs, plhs, 1);
  leveldb::DB* database = Session<leveldb::DB>::get(input.get(0));
  string value;
  leveldb::Status status = database->Get(leveldb::ReadOptions(),
                                         input.get<string>(1),
                                         &value);
  ASSERT(status.ok() || status.IsNotFound(), status.ToString().c_str());
  output.set(0, value);
}

MEX_DEFINE(put) (int nlhs, mxArray* plhs[],
                 int nrhs, const mxArray* prhs[]) {
  InputArguments input(nrhs, prhs, 3, 1, "Sync");
  OutputArguments output(nlhs, plhs, 0);
  leveldb::DB* database = Session<leveldb::DB>::get(input.get(0));
  leveldb::WriteOptions write_options;
  write_options.sync = input.get<bool>("Sync", false);
  leveldb::Status status = database->Put(write_options,
                                         input.get<string>(1),
                                         input.get<string>(2));
  ASSERT(status.ok(), status.ToString().c_str());
}

MEX_DEFINE(remove) (int nlhs, mxArray* plhs[],
                    int nrhs, const mxArray* prhs[]) {
  InputArguments input(nrhs, prhs, 2, 1, "Sync");
  OutputArguments output(nlhs, plhs, 0);
  leveldb::DB* database = Session<leveldb::DB>::get(input.get(0));
  leveldb::WriteOptions write_options;
  write_options.sync = input.get<bool>("Sync", false);
  leveldb::Status status = database->Delete(write_options,
                                            input.get<string>(1));
  ASSERT(status.ok(), status.ToString().c_str());
}

MEX_DEFINE(write) (int nlhs, mxArray* plhs[],
                   int nrhs, const mxArray* prhs[]) {
  InputArguments input(nrhs, prhs, 2, 1, "Sync");
  OutputArguments output(nlhs, plhs, 0);
  leveldb::DB* database = Session<leveldb::DB>::get(input.get(0));
  leveldb::WriteBatch* batch = Session<leveldb::WriteBatch>::get(input.get(1));
  leveldb::WriteOptions write_options;
  write_options.sync = input.get<bool>("Sync", false);
  leveldb::Status status = database->Write(write_options, batch);
  ASSERT(status.ok(), status.ToString().c_str());
}

MEX_DEFINE(batch_new) (int nlhs, mxArray* plhs[],
                       int nrhs, const mxArray* prhs[]) {
  InputArguments input(nrhs, prhs, 0);
  OutputArguments output(nlhs, plhs, 1);
  output.set(0, Session<leveldb::WriteBatch>::create(
      new leveldb::WriteBatch()));
}

MEX_DEFINE(batch_delete) (int nlhs, mxArray* plhs[],
                          int nrhs, const mxArray* prhs[]) {
  InputArguments input(nrhs, prhs, 1);
  OutputArguments output(nlhs, plhs, 0);
  Session<leveldb::WriteBatch>::destroy(input.get(0));
}

MEX_DEFINE(batch_put) (int nlhs, mxArray* plhs[],
                       int nrhs, const mxArray* prhs[]) {
  InputArguments input(nrhs, prhs, 3);
  OutputArguments output(nlhs, plhs, 0);
  leveldb::WriteBatch* batch = Session<leveldb::WriteBatch>::get(input.get(0));
  batch->Put(input.get<string>(1), input.get<string>(2));
}

MEX_DEFINE(batch_remove) (int nlhs, mxArray* plhs[],
                          int nrhs, const mxArray* prhs[]) {
  InputArguments input(nrhs, prhs, 2);
  OutputArguments output(nlhs, plhs, 0);
  leveldb::WriteBatch* batch = Session<leveldb::WriteBatch>::get(input.get(0));
  batch->Delete(input.get<string>(1));
}

MEX_DEFINE(each) (int nlhs, mxArray* plhs[],
                  int nrhs, const mxArray* prhs[]) {
  InputArguments input(nrhs, prhs, 2);
  OutputArguments output(nlhs, plhs, 0);
  leveldb::DB* database = Session<leveldb::DB>::get(input.get(0));
  unique_ptr<leveldb::Iterator> it(
      database->NewIterator(leveldb::ReadOptions()));
  for (it->SeekToFirst(); it->Valid(); it->Next()) {
    MxArray key(it->key().ToString());
    MxArray value(it->value().ToString());
    mxArray* prhs[] = {const_cast<mxArray*>(input.get(1)),
                       const_cast<mxArray*>(key.get()),
                       const_cast<mxArray*>(value.get())};
    ASSERT(mexCallMATLAB(0, NULL, 3, prhs, "feval") == 0, "Callback failure.");
  }
  ASSERT(it->status().ok(), it->status().ToString().c_str());
}

MEX_DEFINE(reduce) (int nlhs, mxArray* plhs[],
                    int nrhs, const mxArray* prhs[]) {
  InputArguments input(nrhs, prhs, 3);
  OutputArguments output(nlhs, plhs, 1);
  leveldb::DB* database = Session<leveldb::DB>::get(input.get(0));
  unique_ptr<leveldb::Iterator> it(
      database->NewIterator(leveldb::ReadOptions()));
  MxArray accumulation(input.get(2));
  for (it->SeekToFirst(); it->Valid(); it->Next()) {
    MxArray key(it->key().ToString());
    MxArray value(it->value().ToString());
    mxArray* lhs = NULL;
    mxArray* prhs[] = {const_cast<mxArray*>(input.get(1)),
                       const_cast<mxArray*>(key.get()),
                       const_cast<mxArray*>(value.get()),
                       const_cast<mxArray*>(accumulation.get())};
    ASSERT(mexCallMATLAB(1, &lhs, 4, prhs, "feval") == 0, "Callback failure.");
    accumulation.reset(lhs);
  }
  ASSERT(it->status().ok(), it->status().ToString().c_str());
  output.set(0, accumulation.release());
}

} // namespace

MEX_DISPATCH
