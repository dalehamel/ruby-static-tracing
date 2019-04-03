/*
System, 3rd party, and project includes
Implements Init_ruby_static_tracing, which is used as C/Ruby entrypoint.
*/

#ifndef RUBY_STATIC_TRACING_H
#define RUBY_STATIC_TRACING_H

typedef enum TRACEPOINT_ARG_TYPES_ENUM {
  Integer = int64,  // STAP enum type -8
  String  = uint64, // STAP enum type 8
} Tracepoint_arg_types;

#include "provider.h"

void Init_ruby_static_tracing();
VALUE eUSDT, eInternal;

#endif //RUBY_STATIC_TRACING_H
