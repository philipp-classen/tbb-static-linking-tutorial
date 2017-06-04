#include <tbb/tbb.h>
#include <thread>
#include <iostream>

// This is a nonsense program, but it should make sure that calls to
// the relevant APIs are made, especially to TBB and to the thread API
// (in general, that means pthread).
//
// If API calls are missing, feel free to extend this file.
//
int main()
{
  // make some API calls to TBB...
  tbb::task_scheduler_init init;
  tbb::task_group_context tbb_context;
  tbb::concurrent_queue<int> queue;

  // make API calls to the thread API.
  // In Linux, that will force to link against pthread.
  std::thread t([&] {});
  t.join();

  std::cout << "It worked!\n";

  return 0;
}
