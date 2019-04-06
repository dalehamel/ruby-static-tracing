#ifndef STATIC_TRACING_TYPES_H
#define STATIC_TRACING_TYPES_H

typedef enum TRACEPOINT_ARG_TYPES_ENUM {
  Integer,
  String,
//  Integer = int64,  // STAP enum type -8
//  String  = uint64, // STAP enum type 8
} Tracepoint_arg_types;

#endif // STATIC_TRACING_TYPES_H
